# Bcb-res

Not sure

## Claude Code backups

Claude Code writes its state to disk as it goes, so an app crash does not lose
your sessions — `claude -c` resumes the last one, `claude -r` picks from a list.
These scripts exist for the two things a crash *doesn't* cover: transcripts
aged out by `cleanupPeriodDays`, and losing the whole machine.

| File | Purpose |
| --- | --- |
| `scripts/claude-backup.sh` | Tars `~/.claude` + `~/.claude.json` to `~/claude-backups`, prunes old snapshots |
| `scripts/com.bcb.claude-backup.plist` | launchd agent template (weekly, Sundays 03:00) |
| `scripts/install-claude-backup.sh` | Installs/removes the agent on macOS |

### Install (macOS)

```bash
./scripts/install-claude-backup.sh
launchctl kickstart -p gui/$(id -u)/com.bcb.claude-backup   # run once now to verify
```

Backups land in `~/claude-backups`, 8 most recent kept (~2 months weekly).
Log: `~/Library/Logs/claude-backup.log`. Remove with
`./scripts/install-claude-backup.sh --uninstall`.

The archives are `chmod 600` because `~/.claude.json` can hold MCP server
credentials. Keep it that way if you copy them elsewhere.

Shell snapshots, statsig telemetry, and cloned plugin repos are excluded —
they're large and regenerate on demand. Transcripts under `~/.claude/projects/`
are kept, since they're the point.

### Manual run

```bash
./scripts/claude-backup.sh                      # defaults
./scripts/claude-backup.sh --dest /Volumes/x --keep 20
```

### Linux

The installer is macOS-only. The backup script itself is portable — run it from
cron or a systemd timer:

```
0 3 * * 0  /path/to/claude-backup.sh
```

### Restore

```bash
tar xzf ~/claude-backups/claude-backup-YYYY-MM-DD-HHMMSS.tgz -C ~
```

Extracting over a live `~/.claude` overwrites settings and transcripts, so quit
Claude Code first, and move the current `~/.claude` aside if you want to keep it.

### Keeping transcripts longer

Backups don't help with sessions already deleted. `cleanupPeriodDays` defaults
to 30 — raise it in `~/.claude/settings.json`:

```json
{ "cleanupPeriodDays": 365 }
```
