$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.config.buffer_editor = 'nvim'
$env.config.table.mode = 'light' # compact
$env.config.color_config.hints = 'grey7'

$env.PROMPT_COMMAND_RIGHT = ''
$env.NIXPKGS_ALLOW_UNFREE = 1

alias lf = yazi
alias ccd = cd (ls ~/sw/*/.git | get name | str replace '/.git' '' | input list --fuzzy)
def ts [] { ls ~/sw/*/.git | get name | str replace '/.git' '' | input list --fuzzy | $env.dir = { path: $in, name: ($in | path basename) }; try { tmux new-session -c $env.dir.path -ds $env.dir.name }; try { tmux a }; tmux switch-client -t $env.dir.name }
