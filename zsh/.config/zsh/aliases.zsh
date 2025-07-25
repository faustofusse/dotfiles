alias l="ls -l"
alias ll="ls -l"
alias la="ls -la"
alias lg="lazygit"
alias lf="yazi"
alias ccd="cd \$(find ~/sw -maxdepth 4 -type d -name .git -print | sed -e 's/\/.git//g' | fzf --reverse)"
# alias ts="nu -c \"ls ~/sw/*/.git | get name | str replace '/.git' '' | input list --fuzzy | $(echo '\$')env.dir = { path: $(echo '\$')in, name: ($(echo '\$')in | path basename) }; try { tmux new-session -c $(echo '\$')env.dir.path -ds $(echo '\$')env.dir.name}; try { tmux a }; tmux switch-client -t $(echo '\$')env.dir.name\""
alias tsm="transmission-remote"
alias nchat="TERM=xterm-256color nchat"
alias nix="NIXPKGS_ALLOW_UNFREE=1 nix"
