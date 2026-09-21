#!/usr/bin/env bash
# Records pane focus order so the goto picker can sort by most recently visited.
# Auto-started by goto-search.sh; safe to run from a [[startup]] hook too.
set -euo pipefail

SOCK="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
STATE_DIR="$HOME/.local/state/herdr"
MRU="$STATE_DIR/pane-mru"
PIDFILE="$STATE_DIR/mru-tracker.pid"

mkdir -p "$STATE_DIR"

# Single instance.
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
  exit 0
fi
echo $$ >"$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

# Hold stdin open for the life of the subscription, or the server hangs up.
{
  printf '{"id":"mru","method":"events.subscribe","params":{"subscriptions":[{"type":"pane.focused"}]}}\n'
  while :; do sleep 3600; done
} | nc -U "$SOCK" 2>/dev/null \
  | while IFS= read -r line; do
      pane="$(printf '%s' "$line" | jq -r 'select(.event=="pane_focused") | .data.pane_id // empty' 2>/dev/null)" || continue
      [ -z "$pane" ] && continue
      tmp="$(mktemp "$MRU.XXXXXX")"
      {
        printf '%s\n' "$pane"
        [ -f "$MRU" ] && grep -vxF "$pane" "$MRU" | head -n 200
      } >"$tmp" 2>/dev/null || true
      mv -f "$tmp" "$MRU"
    done
