export ZSH="/Users/faustofusse/.oh-my-zsh"

# path
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/Users/faustofusse/.local/bin"
export PATH="$PATH:/usr/local/Cellar/openvpn/2.5.3/sbin"

# theme
ZSH_THEME="robbyrussell" # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# pyenv
eval "$(pyenv init -)" 

# android
export ANDROID_HOME=/Users/faustofusse/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK/emulator:$PATH

# plugins
plugins=( git bundler dotenv osx rake rbenv ruby zsh-completions pyenv )

# zsh config
source $ZSH/oh-my-zsh.sh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload -U compinit && compinit

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# Aliases
alias ghcid="stack exec ghcid -- --command 'stack ghci'" # --run=correrTests
alias ghci="stack ghci"
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias ffpb="python -m ffpb"
alias himym="python ~/Documents/Software/Python/himym.py"
alias stopvshield="sudo /usr/local/McAfee/AntiMalware/VSControl stopoas" 

alias dulcinea="sshpass -p 20053131 ssh -t dulci@192.168.0.47"
alias valeria="sshpass -p Valeria4507 ssh -t mariavaleriarebora@192.168.0.12"

alias ubuntu="clear && vboxmanage startvm \"Ubuntu Server 5.0.1\" --type headless"
alias closeubuntu="vboxmanage controlvm \"Ubuntu Server 5.0.1\" poweroff soft"
alias lubuntu="vboxmanage startvm \"Lubuntu 5.0.1\" --type headless"
alias closelubuntu="vboxmanage controlvm \"Lubuntu 5.0.1\" poweroff soft"
alias utnso="clear && sshpass -p utnso ssh -t utnso@192.168.0.161 'cd /home/utnso; bash -l; clear' && clear"

clear # && neofetch #--iterm2 --source hola.png
