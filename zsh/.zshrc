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

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/fausto/.lmstudio/bin"
# End of LM Studio CLI section

export DIRENV_LOG_FORMAT=
export PATH=$PATH:$HOME/.maestro/bin
