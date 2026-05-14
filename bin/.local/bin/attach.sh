#!/usr/bin/env bash
set -euo pipefail

# nu -c "ls ~/sw/*/.git | get name | str replace '/.git' '' | input list --fuzzy | tmux new-session -c \$in -ds (\$in | path basename)"

if [[ $# -eq 1 ]]; then
    selected_dir=$1
else
    selected_dir=$(find ~/.dotfiles ~/sw ~/dex -maxdepth 4 -name .git -print | sed -e 's/\/.git//g' | sed -e "s/$(echo ~ | sed -e 's/\//\\\//g')/~/g" | fzf --reverse)
fi

if [[ -z $selected_dir ]]; then
    exit 0
fi

selected_name=$(basename "$selected_dir" | tr . _)

pipe_path="$HOME/.cache/nvim/${selected_name}.pipe"
mkdir -p "$HOME/.cache/nvim"

if [[ -e "$pipe_path" ]]; then
    nvim --server "$pipe_path" --remote-ui
else
    nvim --listen "$pipe_path" --headless --cmd "cd $selected_dir" &
    
    # Wait for the socket to be created
    while [[ ! -e "$pipe_path" ]]; do
        sleep 0.1
    done
    
    nvim --server "$pipe_path" --remote-ui
fi
