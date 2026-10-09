alias lf="yazi"
alias ccd="cd \$(find ~/sw -maxdepth 4 -type d -name .git -print | sed -e 's/\/.git//g' | fzf --reverse)"
# alias ts="nu -c \"ls ~/sw/*/.git | get name | str replace '/.git' '' | input list --fuzzy | $(echo '\$')env.dir = { path: $(echo '\$')in, name: ($(echo '\$')in | path basename) }; try { tmux new-session -c $(echo '\$')env.dir.path -ds $(echo '\$')env.dir.name}; try { tmux a }; tmux switch-client -t $(echo '\$')env.dir.name\""
alias tsm="transmission-remote"
alias oc="opencode"
alias occ="opencode --continue"
alias ocp="opencode --port"
# alias v="nvim"
alias ve="v ."
alias vg="v -c Git -c +q"
alias vf="v -c \"lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))\" -c +q"
alias vd="v -c \"lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({ cwd = '~/.dotfiles', hidden = true }))\" -c +q"
alias claudex='CLAUDE_CONFIG_DIR=~/.claude-dex claude --strict-mcp-config --tools "Read,Edit,Write,Bash,Skill" --system-prompt-file ~/.claude/minimal-prompt.md'
alias cm='claude --tools "Read,Edit,Write,Bash" --system-prompt-file ~/.claude/minimal-prompt.md --strict-mcp-config --disable-slash-commands --setting-sources "" --settings ~/.claude/minimal.json --dangerously-skip-permissions'
