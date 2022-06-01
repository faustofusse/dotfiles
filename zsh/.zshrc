# zsh config
ZSH_THEME="common" # robbyrussel, lambda-gitster, typewritten, common, bunnyruni, another, logico, pi
export ZSH="/Users/faustofusse/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload -U compinit && compinit
plugins=( git bundler dotenv macos rake rbenv ruby zsh-completions pyenv vi-mode )

# java
export JDTLS_HOME='/Library/Java/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository'
# export JAVA_HOME='/Library/Java/JavaVirtualMachines/jdk-17.0.1.jdk/Contents/Home'
# export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home'
export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home'
export PATH="$JAVA_HOME/bin:$PATH"

# ruby
export PATH="$PATH:$HOME/.rvm/bin"

# golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# path
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/usr/local/Cellar/openvpn/2.5.3/sbin"

# arch
export ARCHFLAGS="-arch x86_64"
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"

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
export LANG=en_US.UTF-8

# clangd
export PATH="$PATH:/usr/local/opt/llvm/bin"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"

# ESP8266
export IDF_PATH=~/esp/ESP8266_RTOS_SDK
export PATH="$PATH:$HOME/esp/ESP8266_RTOS_SDK/xtensa-lx106-elf/bin"

# Functions
function acp() {
  git add .
  git commit -m "$1"
  git push
}

# Aliases
alias imprimir="lp -o portrait -o fit-to-page -o media=A4" # -P 1,2,3,4
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias ffpb="python -m ffpb"
alias stopvshield="sudo /usr/local/McAfee/AntiMalware/VSControl stopoas" 

alias startvm="vboxmanage list vms | fzf --layout=reverse | xargs echo | sed 's/{.*}//g;s/.$//g' | xargs -I_ bash -c 'vboxmanage startvm \"_\" --type headless'"
alias stopvm="vboxmanage list runningvms | fzf --layout=reverse | xargs echo | sed 's/{.*}//g;s/.$//g' | xargs -I_ bash -c 'vboxmanage controlvm \"_\" poweroff soft'"

alias utnso="clear && sshpass -p utnso ssh -t utnso@127.0.0.1 -p 2222 'cd /home/utnso; bash -l; clear' && clear"
alias ssharch="sshpass -p fausto ssh -t fausto@127.0.0.1 -p 7999 'zsh; clear'"

alias lg="lazygit"
alias :q="exit"
alias v="nvim"
alias ccd="cd \"\$(findproject)\" && clear"
alias cvim="cd \"\$(findproject)\" && clear && nvim"

# clear && neofetch # --source hola.png
clear
