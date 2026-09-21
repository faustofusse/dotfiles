#!/usr/bin/env bash
# Opens a horizontal split at the top of the focused pane running Neovim
# with :Git (Fugitive) so you can manage the repo's Git status.
# Bound via [[keys.command]] type="shell" as prefix+d in config.toml
set -euo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"
SOCK="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
ACTIVE="${HERDR_ACTIVE_PANE_ID:?no active pane}"
CWD="${HERDR_ACTIVE_PANE_CWD:-}"

# Spawn the new pane's shell in $HOME instead of the project directory.
# Starting it in the project dir would run the zsh direnv hook and, for
# flake-based projects, trigger a full `nix develop` build before the
# shell is ready for input — delaying Neovim for no reason, since we
# only need Neovim's cwd (set below with -c cd) to be the project dir.
split_args=(pane split --pane "$ACTIVE" --direction down --ratio 0.6 --cwd "$HOME" --focus)

new_pane="$("$HERDR" "${split_args[@]}" | jq -r '.result.pane.pane_id // empty')"
if [ -z "$new_pane" ]; then
  exit 1
fi

# The new pane opens below the source pane; swap the two so the
# Neovim/Fugitive pane ends up on top and the original pane moves down.
"$HERDR" pane swap --source-pane "$ACTIVE" --target-pane "$new_pane" >/dev/null

# `command nvim` bypasses any shell alias/function named nvim (or v).
# `-c cd ...` moves Neovim into the project dir (without touching the
# shell's own cwd/direnv). `-c only` closes the empty starting window
# so only the Fugitive status buffer is visible.
if [ -n "$CWD" ]; then
  # Double-quote (not single-quote) the path inside the -c argument: the
  # receiving shell only strips the outer double quotes, so any nested
  # single quotes would be passed to Neovim's `cd` literally and break it.
  nvim_cmd="command nvim -c \"cd $CWD\" -c Git -c only"
else
  nvim_cmd="command nvim -c Git -c only"
fi

# Close this pane as soon as Neovim exits (success or failure) instead of
# leaving a bare shell prompt behind.
"$HERDR" pane run "$new_pane" "$nvim_cmd; \"$HERDR\" pane close $new_pane"

# Focus follows pane identity, not screen position, so re-focus the
# Fugitive pane explicitly after the split/swap.
printf '{"id":"git-panel","method":"pane.focus","params":{"pane_id":"%s"}}\n' "$new_pane" \
  | nc -U "$SOCK" >/dev/null 2>&1 || true
