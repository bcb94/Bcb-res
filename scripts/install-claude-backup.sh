#!/usr/bin/env bash
#
# Install (or remove) the weekly Claude Code backup launchd agent on macOS.
#
# Usage:
#   ./scripts/install-claude-backup.sh
#   ./scripts/install-claude-backup.sh --uninstall

set -euo pipefail

LABEL="com.bcb.claude-backup"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DEST="$BIN_DIR/claude-backup.sh"
AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_DEST="$AGENT_DIR/$LABEL.plist"
LOG="$HOME/Library/Logs/claude-backup.log"

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="gui/$(id -u)"

die() { echo "install-claude-backup: $*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "this installer is macOS-only (launchd). On Linux, run scripts/claude-backup.sh from cron or a systemd timer."

if [ "${1:-}" = "--uninstall" ]; then
  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  rm -f "$PLIST_DEST"
  echo "Removed $LABEL. Left $SCRIPT_DEST and existing backups in place."
  exit 0
fi

[ $# -eq 0 ] || die "unknown argument: $1"
[ -f "$SRC_DIR/claude-backup.sh" ] || die "claude-backup.sh not found next to this installer"
[ -f "$SRC_DIR/$LABEL.plist" ] || die "$LABEL.plist not found next to this installer"

mkdir -p "$BIN_DIR" "$AGENT_DIR" "$(dirname "$LOG")"

install -m 755 "$SRC_DIR/claude-backup.sh" "$SCRIPT_DEST"
echo "Installed $SCRIPT_DEST"

sed -e "s|@SCRIPT@|$SCRIPT_DEST|g" -e "s|@LOG@|$LOG|g" \
  "$SRC_DIR/$LABEL.plist" > "$PLIST_DEST"
chmod 644 "$PLIST_DEST"
plutil -lint "$PLIST_DEST" >/dev/null || die "generated plist failed validation"
echo "Installed $PLIST_DEST"

# bootout first so re-running the installer picks up an edited plist.
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST_DEST"
launchctl enable "$DOMAIN/$LABEL"

echo
echo "Installed. Weekly, Sundays at 03:00 local."
echo "  Backups: ~/claude-backups (8 most recent kept)"
echo "  Log:     $LOG"
echo
echo "Run it once now to confirm:  launchctl kickstart -p $DOMAIN/$LABEL"
echo "Check it is loaded:          launchctl print $DOMAIN/$LABEL | head"
echo "Remove it later:             $0 --uninstall"
