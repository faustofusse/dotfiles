# zsh config
ZSH_THEME="robbyrussell" # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
export ZSH="/Users/faustofusse/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload -U compinit && compinit
plugins=( git bundler dotenv macos rake rbenv ruby zsh-completions pyenv vi-mode )

# java
export JDTLS_HOME='/Library/Java/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository'
# export JAVA_HOME='/Library/Java/JavaVirtualMachines/jdk-17.0.1.jdk/Contents/Home'
export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home'
# export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home'
export PATH="$JAVA_HOME/bin:$PATH"
# export PATH="$PATH:/usr/local/opt/openjdk/bin"

# wollok
export PATH="$PATH:/Applications/Wollok.app/Contents/wollok-cli"

# golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# path
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/Users/faustofusse/.local/bin"
export PATH="$PATH:/usr/local/Cellar/openvpn/2.5.3/sbin"


# pyenv
eval "$(pyenv init -)" 

# android
export ANDROID_HOME=/Users/faustofusse/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK/emulator:$PATH

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# clangd
export PATH="$PATH:/usr/local/opt/llvm/bin"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"

# ESP8266
export IDF_PATH=~/esp/ESP8266_RTOS_SDK
export PATH="$PATH:$HOME/esp/ESP8266_RTOS_SDK/xtensa-lx106-elf/bin"
# export PATH="$PATH:$HOME/esp/ESP8266_RTOS_SDK/xtensa-lx106-elf/xtensa-lx106-elf/bin"

# Functions
function acp() {
  git add .
  git commit -m "$1"
  git push
}

# Aliases
alias imprimir="lp -o portrait -o fit-to-page -o media=A4" # -P 1,2,3,4
alias ghcid="stack exec ghcid -- --command 'stack ghci'" # --run=correrTests
alias ghci="stack ghci"
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias ffpb="python -m ffpb"
alias himym="python ~/Documents/Software/scripts/python/himym.py"
alias stopvshield="sudo /usr/local/McAfee/AntiMalware/VSControl stopoas" 

alias dulcinea="sshpass -p 20053131 ssh -t dulci@192.168.0.47"
alias valeria="sshpass -p Valeria4507 ssh -t mariavaleriarebora@192.168.0.12"

alias ubuntu="clear && vboxmanage startvm \"Ubuntu Server 5.0.1\" --type headless"
alias closeubuntu="vboxmanage controlvm \"Ubuntu Server 5.0.1\" poweroff soft"
alias lubuntu="vboxmanage startvm \"Lubuntu 5.0.1\" --type headless"
alias closelubuntu="vboxmanage controlvm \"Lubuntu 5.0.1\" poweroff soft"
alias utnso="clear && sshpass -p utnso ssh -t utnso@127.0.0.1 -p 2222 'cd /home/utnso; bash -l; clear' && clear"

alias startmanjaro="vboxmanage startvm \"Manjaro\" --type headless"
alias closemanjaro="vboxmanage controlvm \"Manjaro\" poweroff soft"
alias manjaro="clear && sshpass -p utnso ssh -t utn_so@127.0.0.1 -p 7999 'cd; bash -l; clear' && clear"

alias lg="lazygit"
alias :q="exit"
alias v="nvim"
alias ccd="cd \"\$(findproject)\" && clear"
alias cvim="cd \"\$(findproject)\" && clear && nvim"
alias ccode="code \"\$(findproject)\" && exit"
alias csubl="subl \"\$(findproject)\" && exit"

alias get_idf='. $HOME/esp/esp-idf/export.sh'

# bases=`osascript -e "tell application \"iTerm\" to tell current tab of current window to sessions" | xargs -n 1` 

# clear && neofetch # --source hola.png
clear
