# Hooks

Self-contained Node scripts (no dependencies, no install step) wired up by
`../settings.json`. They are referenced by paths relative to the project root,
which resolve identically under bash and PowerShell — no `$CLAUDE_PROJECT_DIR`
expansion, so the same config works on Windows, macOS and Linux.

| Script | Event | What it does |
| --- | --- | --- |
| `statusline.mjs` | status line | Renders `dir · on branch* · model · $cost`. |
| `context-guard.mjs` | `UserPromptSubmit` | Warns once per size tier (2/5/10 MB) as the session transcript grows, suggesting `/compact`. |
| `auto-handoff.mjs` | `UserPromptSubmit`, `PreCompact` | Logs each prompt, and on compaction writes `../HANDOFF.md` with git state and recent prompts. |

Shared stdin/stdout helpers live in `_hookio.mjs`.

## Conventions

Every hook fails open: unreadable stdin, missing files and failed git calls are
swallowed, and each script exits 0. A hook should never be the reason a prompt
does not go through.

Scratch output (`.claude/.state/`, `.claude/HANDOFF.md`) is gitignored.

## Testing one by hand

```sh
echo '{"hook_event_name":"PreCompact","cwd":"'"$PWD"'"}' | node .claude/hooks/auto-handoff.mjs
```

After editing `settings.json`, open `/hooks` once so Claude Code reloads it.
