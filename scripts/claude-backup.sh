#!/usr/bin/env bash
#
# Snapshot Claude Code's on-disk state (~/.claude and ~/.claude.json) to a
# timestamped tarball, then prune old snapshots.
#
# Usage:
#   claude-backup.sh [--dest DIR] [--keep N]
#
# Environment overrides:
#   CLAUDE_BACKUP_DEST   destination directory (default: ~/claude-backups)
#   CLAUDE_BACKUP_KEEP   number of snapshots to retain (default: 8)

set -euo pipefail

DEST="${CLAUDE_BACKUP_DEST:-$HOME/claude-backups}"
KEEP="${CLAUDE_BACKUP_KEEP:-8}"

while [ $# -gt 0 ]; do
  case "$1" in
    --dest) DEST="${2:?--dest needs a directory}"; shift 2 ;;
    --keep) KEEP="${2:?--keep needs a number}"; shift 2 ;;
    -h|--help) awk 'NR>1 && !/^#/{exit} NR>1{sub(/^# ?/, ""); print}' "$0"; exit 0 ;;
    *) echo "claude-backup: unknown argument: $1" >&2; exit 2 ;;
  esac
done

case "$KEEP" in
  ''|*[!0-9]*) echo "claude-backup: --keep must be a non-negative integer" >&2; exit 2 ;;
esac

log() { printf '%s claude-backup: %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*"; }

# Collect whatever actually exists; a missing ~/.claude.json is normal on a
# fresh install and must not fail the run.
sources=()
[ -d "$HOME/.claude" ] && sources+=(".claude")
[ -f "$HOME/.claude.json" ] && sources+=(".claude.json")

if [ ${#sources[@]} -eq 0 ]; then
  log "nothing to back up (no ~/.claude or ~/.claude.json); exiting"
  exit 0
fi

mkdir -p "$DEST"

stamp="$(date '+%Y-%m-%d-%H%M%S')"
archive="$DEST/claude-backup-$stamp.tgz"
tmp="$archive.partial"

cleanup() { rm -f "$tmp"; }
trap cleanup EXIT

# Caches and telemetry that are large, regenerated on demand, and worthless in
# a restore. Everything else under ~/.claude is kept, transcripts included.
excludes=(
  --exclude='.claude/shell-snapshots'
  --exclude='.claude/statsig'
  --exclude='.claude/.tmp'
  --exclude='.claude/plugins/repos'
)

log "archiving ${sources[*]} -> $archive"

# COPYFILE_DISABLE stops macOS bsdtar from emitting ._ AppleDouble members.
COPYFILE_DISABLE=1 tar czf "$tmp" -C "$HOME" "${excludes[@]}" "${sources[@]}"

# These files can contain MCP server credentials and API keys, so keep the
# archive readable only by its owner.
chmod 600 "$tmp"
mv "$tmp" "$archive"
trap - EXIT

log "wrote $archive ($(du -h "$archive" | cut -f1))"

if [ "$KEEP" -gt 0 ]; then
  # Names are timestamp-sorted, so lexical order is chronological. Kept
  # portable for macOS's bash 3.2 and BSD head: no mapfile, no `head -n -N`.
  total="$(ls -1 "$DEST"/claude-backup-*.tgz 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$total" -gt "$KEEP" ]; then
    ls -1 "$DEST"/claude-backup-*.tgz 2>/dev/null | sort | sed -n "1,$((total - KEEP))p" |
      while IFS= read -r old; do
        log "pruning $old"
        rm -f "$old"
      done
  fi
fi

log "done"
