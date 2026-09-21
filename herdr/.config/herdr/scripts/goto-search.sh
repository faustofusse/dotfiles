#!/usr/bin/env bash
# Goto picker that opens straight into search/filter mode.
# Sorted by most recently visited, falling back to workspace order (left/top first).
# Bound via [[keys.command]] type="popup" in ~/.config/herdr/config.toml
set -euo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"
SOCK="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$HOME/.local/state/herdr"
MRU="$STATE_DIR/pane-mru"

mkdir -p "$STATE_DIR"

# Title the popup surface (OSC 2). Without this the border just reads "popup".
set_title() { printf '\033]2;%s\007' "$1"; }
if [ -w /dev/tty ]; then set_title 'Goto — jump to pane' >/dev/tty; else set_title 'Goto — jump to pane'; fi

# Keep the focus-history tracker alive (no-op if already running).
nohup "$SCRIPT_DIR/mru-tracker.sh" >/dev/null 2>&1 &
disown 2>/dev/null || true

panes_json="$("$HERDR" pane list 2>/dev/null)"
ws_json="$("$HERDR" workspace list 2>/dev/null)"

# Current pane sorts last: you are already there.
current="$(printf '%s' "$panes_json" | jq -r '.result.panes[] | select(.focused) | .pane_id' | head -n1)"

# MRU rank: 0 = most recent. Unvisited panes get a large rank and fall back to
# workspace number, then pane number, so they read left/top first.
rows="$(
  jq -rn \
    --argjson panes "$panes_json" \
    --argjson ws "$ws_json" \
    --arg mru "$( [ -f "$MRU" ] && cat "$MRU" || true )" \
    --arg current "$current" \
    --arg home "$HOME" '
      ($mru | split("\n") | map(select(length > 0))) as $order
    | (reduce range(0; $order | length) as $i ({}; .[$order[$i]] = $i)) as $rank
    | ($ws.result.workspaces // []) as $w
    | (reduce $w[] as $x ({}; .[$x.workspace_id] = $x.label)) as $wlabel
    | (reduce $w[] as $x ({}; .[$x.workspace_id] = ($x.number // 999))) as $wnum
    | [ $panes.result.panes[]
        | . + {
            _rank: ($rank[.pane_id] // 100000),
            _wnum: ($wnum[.workspace_id] // 999),
            _pnum: (.pane_id | split(":")[1] | ltrimstr("p") | tonumber? // 0),
            _cur:  (if .pane_id == $current then 1 else 0 end)
          }
      ]
    | sort_by(._cur, ._rank, ._wnum, ._pnum)
    | .[]
    | [ .pane_id,
        ( ($wlabel[.workspace_id] // .workspace_id)
          + " · " + (.tab_id | split(":")[1])
          + (if .agent then " · " + .agent else "" end)
          + (if .agent_status and .agent_status != "unknown"
             then " [" + .agent_status + "]" else "" end)
          + " · " + ((.foreground_cwd // .cwd) | sub("^" + $home; "~"))
          + (if .terminal_title_stripped
             then " · " + .terminal_title_stripped else "" end)
          + (if ._cur == 1 then "  (current)"
             elif ._rank < 100000 then "  ·" else "" end) )
      ] | @tsv
    '
)"

[ -z "$rows" ] && exit 0

sel="$(
  printf '%s\n' "$rows" | fzf \
    --delimiter='\t' --with-nth=2 \
    --prompt='goto > ' \
    --header='recent first · type to search · enter to jump · esc to cancel' \
    --height=100% --layout=reverse --info=inline --cycle --no-sort \
    --color='prompt:cyan,pointer:magenta,marker:green' \
  | cut -f1
)" || exit 0

[ -z "$sel" ] && exit 0

printf '{"id":"goto","method":"pane.focus","params":{"pane_id":"%s"}}\n' "$sel" \
  | nc -U "$SOCK" >/dev/null 2>&1
