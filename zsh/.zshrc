if [[ $(uname) == "Darwin" ]]; then
    source ~/.config/zsh/macos.zsh
else
    source ~/.config/zsh/linux.zsh
fi

source ~/.config/zsh/theme.zsh
source ~/.config/zsh/history.zsh
source ~/.config/zsh/options.zsh
source ~/.config/zsh/keymaps.zsh
source ~/.config/zsh/aliases.zsh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
