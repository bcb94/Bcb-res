#!/usr/bin/env node
// Keeps a handoff note current so work survives a compaction or a new session.
//
// UserPromptSubmit -> append the prompt to a rolling log (cheap, every turn).
// PreCompact       -> write .claude/HANDOFF.md from that log plus git state.
//
// Both outputs are gitignored: the note is a scratch aid, not repo content.
import { mkdir, readFile, writeFile } from 'node:fs/promises'
import { execFileSync } from 'node:child_process'
import { dirname, join } from 'node:path'
import { readHookInput, respond } from './_hookio.mjs'

const KEEP_PROMPTS = 50
const SHOW_PROMPTS = 10

function git(args, cwd) {
  try {
    return execFileSync('git', args, {
      cwd,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
      timeout: 3000,
    }).trim()
  } catch {
    return ''
  }
}

const input = await readHookInput()
const projectDir = input?.cwd || process.cwd()
const logFile = join(projectDir, '.claude', '.state', 'prompts.jsonl')
const handoffFile = join(projectDir, '.claude', 'HANDOFF.md')

async function readLog() {
  try {
    return (await readFile(logFile, 'utf8'))
      .split('\n')
      .filter(Boolean)
      .map((line) => {
        try { return JSON.parse(line) } catch { return null }
      })
      .filter(Boolean)
  } catch {
    return []
  }
}

const event = input?.hook_event_name

if (event === 'UserPromptSubmit') {
  const prompt = String(input?.prompt ?? '').trim()
  if (!prompt) respond({})
  const entries = await readLog()
  entries.push({ ts: new Date().toISOString(), prompt: prompt.slice(0, 2000) })
  try {
    await mkdir(dirname(logFile), { recursive: true })
    await writeFile(
      logFile,
      entries.slice(-KEEP_PROMPTS).map((e) => JSON.stringify(e)).join('\n') + '\n',
    )
  } catch {}
  respond({})
}

// Anything else (PreCompact, or a manual run) writes the handoff note.
const entries = await readLog()
const branch = git(['rev-parse', '--abbrev-ref', 'HEAD'], projectDir)
const status = git(['status', '--porcelain'], projectDir)
const commits = git(['log', '--oneline', '-10'], projectDir)

const lines = [
  '# Handoff',
  '',
  `Written ${new Date().toISOString()} by the auto-handoff hook (trigger: ${input?.trigger || event || 'manual'}).`,
  '',
  '## Git',
  '',
  `- Branch: \`${branch || 'unknown'}\``,
  `- Working tree: ${status ? `${status.split('\n').length} changed file(s)` : 'clean'}`,
  '',
]

if (status) {
  lines.push('```', status.split('\n').slice(0, 40).join('\n'), '```', '')
}
if (commits) {
  lines.push('## Recent commits', '', '```', commits, '```', '')
}
if (entries.length) {
  lines.push('## Recent prompts', '')
  for (const entry of entries.slice(-SHOW_PROMPTS)) {
    const text = entry.prompt.replace(/\s+/g, ' ').slice(0, 300)
    lines.push(`- \`${entry.ts}\` ${text}`)
  }
  lines.push('')
}

try {
  await mkdir(dirname(handoffFile), { recursive: true })
  await writeFile(handoffFile, lines.join('\n'))
} catch {
  respond({})
}

respond({ systemMessage: `Handoff note written to .claude/HANDOFF.md` })
