// Shared helpers for the hooks in this directory.
// Every hook must fail open: a broken hook should never block a prompt.

/** Read the hook payload Claude Code sends on stdin. Returns {} on anything unexpected. */
export async function readHookInput(timeoutMs = 2000) {
  if (process.stdin.isTTY) return {}
  let raw = ''
  const timer = setTimeout(() => {
    try { process.stdin.destroy() } catch {}
  }, timeoutMs)
  try {
    for await (const chunk of process.stdin) raw += chunk
  } catch {}
  clearTimeout(timer)
  try { return JSON.parse(raw) } catch { return {} }
}

/** Emit a hook JSON response and exit cleanly. */
export function respond(payload) {
  if (payload && Object.keys(payload).length > 0) {
    process.stdout.write(JSON.stringify(payload))
  }
  process.exit(0)
}

/** Read the tail of a file without pulling a huge transcript into memory. */
export async function readTail(path, maxBytes = 256 * 1024) {
  const { open, stat } = await import('node:fs/promises')
  let handle
  try {
    const info = await stat(path)
    const start = Math.max(0, info.size - maxBytes)
    handle = await open(path, 'r')
    const length = info.size - start
    const buf = Buffer.alloc(length)
    await handle.read(buf, 0, length, start)
    return buf.toString('utf8')
  } catch {
    return ''
  } finally {
    try { await handle?.close() } catch {}
  }
}
