#!/usr/bin/env node
// Status line: <dir> on <branch><dirty> · <model> · <cost>
// Receives the session JSON on stdin. Every field is treated as optional.
import { basename } from 'node:path'
import { execFileSync } from 'node:child_process'
import { readHookInput } from './_hookio.mjs'

const DIM = '\x1b[2m'
const RESET = '\x1b[0m'
const CYAN = '\x1b[36m'
const YELLOW = '\x1b[33m'

function git(args, cwd) {
  try {
    return execFileSync('git', args, {
      cwd,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
      timeout: 2000,
    }).trim()
  } catch {
    return ''
  }
}

const input = await readHookInput()
const cwd = input?.workspace?.current_dir || input?.cwd || process.cwd()

const parts = [`${CYAN}${basename(cwd)}${RESET}`]

const branch = git(['rev-parse', '--abbrev-ref', 'HEAD'], cwd)
if (branch) {
  const dirty = git(['status', '--porcelain'], cwd) ? '*' : ''
  parts.push(`${DIM}on${RESET} ${YELLOW}${branch}${dirty}${RESET}`)
}

const model = input?.model?.display_name || input?.model?.id
if (model) parts.push(`${DIM}${model}${RESET}`)

const cost = input?.cost?.total_cost_usd
if (typeof cost === 'number' && cost > 0) parts.push(`${DIM}$${cost.toFixed(2)}${RESET}`)

const vim = input?.vim?.mode
if (vim) parts.push(`${DIM}-- ${String(vim).toUpperCase()} --${RESET}`)

process.stdout.write(parts.join(` ${DIM}·${RESET} `))
