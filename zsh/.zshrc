source ~/.config/zsh/theme.zsh
source ~/.config/zsh/history.zsh
source ~/.config/zsh/options.zsh
source ~/.config/zsh/keymaps.zsh
source ~/.config/zsh/aliases.zsh

if [[ $(uname) == "Darwin" ]]; then
    source ~/.config/zsh/macos.zsh
else
    source ~/.config/zsh/linux.zsh
fi
