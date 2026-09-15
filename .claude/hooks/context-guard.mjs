#!/usr/bin/env node
// UserPromptSubmit guard: warn once per tier as the session transcript grows,
// so a long session gets a nudge to /compact or hand off before it runs hot.
//
// Transcript size is a proxy for context pressure, not a measurement of it --
// it keeps growing across compactions. Treat the warning as "this session is
// long", not "you are N tokens from the limit".
import { mkdir, readFile, writeFile, stat } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { readHookInput, respond } from './_hookio.mjs'

const TIERS = [
  { mb: 2, message: 'Session transcript is past 2 MB. Long session -- consider /compact at a natural break.' },
  { mb: 5, message: 'Session transcript is past 5 MB. Worth running /compact, or starting fresh with a handoff.' },
  { mb: 10, message: 'Session transcript is past 10 MB. Strongly consider /compact or a new session.' },
]

const input = await readHookInput()
const transcript = input?.transcript_path
if (!transcript) respond({})

const projectDir = input?.cwd || process.cwd()
const stateFile = join(projectDir, '.claude', '.state', 'context-guard.json')

let sizeMb = 0
try {
  sizeMb = (await stat(transcript)).size / (1024 * 1024)
} catch {
  respond({})
}

const tier = TIERS.filter((t) => sizeMb >= t.mb).pop()
if (!tier) respond({})

const sessionId = input?.session_id || 'unknown'
let state = {}
try {
  state = JSON.parse(await readFile(stateFile, 'utf8'))
} catch {}

if (state[sessionId] >= tier.mb) respond({})

state[sessionId] = tier.mb
try {
  await mkdir(dirname(stateFile), { recursive: true })
  await writeFile(stateFile, JSON.stringify(state, null, 2))
} catch {}

respond({ systemMessage: `${tier.message} (${sizeMb.toFixed(1)} MB)` })
