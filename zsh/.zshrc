# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"

# zsh config
ZSH_THEME="lambda-gitster" # robbyrussel, lambda-gitster, typewritten, common, logico, pi
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
plugins=( git bundler macos rake rbenv ruby pyenv vi-mode )

# aliases
alias nchat="TERM=xterm-256color nchat"
alias lg="lazygit"
alias v="nvim"
alias ccd="cd \"\$(findproject)\" && clear"
alias wpp="TERM=xterm-256color nchat"

# path
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"

# openvpn (commented on 02/aug/2022)
export PATH="$PATH:/usr/local/Cellar/openvpn/2.5.8/sbin"

# dart
export PATH="$PATH":"$HOME/.pub-cache/bin"

# rust
source "$HOME/.cargo/env"

# java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home"
export PATH="$PATH:$JAVA_HOME/bin"

# ruby
eval "$(rbenv init - zsh)"
export PATH="$PATH:$HOME/.rvm/bin"

# golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# arch
export ARCHFLAGS="-arch x86_64"
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"

# pyenv
eval "$(pyenv init -)" 
eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=2
export BASE_PROMPT=$PS1
function updatePrompt {
    if [[ "$(pyenv version-name)" != "system" ]]; then
        # the next line should be double quote; single quote would not work for me
        export PS1="($(pyenv version-name)) "$BASE_PROMPT 
    else
        export PS1=$BASE_PROMPT
    fi
}
export PROMPT_COMMAND='updatePrompt'
precmd() { eval '$PROMPT_COMMAND' } # this line is necessary for zsh

# android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# User configuration
export MANPATH="$PATH:/usr/local/man"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
export LANG=en_US.UTF-8

# clangd (si lo descomento rompe los 'pod install')
# export PATH="$PATH:/usr/local/opt/llvm/bin"
# export LDFLAGS="-L/usr/local/opt/llvm/lib"
# export CPPFLAGS="-I/usr/local/opt/llvm/include"

# ESP8266
export IDF_PATH=~/esp/ESP8266_RTOS_SDK
export PATH="$PATH:$HOME/esp/ESP8266_RTOS_SDK/xtensa-lx106-elf/bin"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/fausto/.bun/_bun" ] && source "/Users/fausto/.bun/_bun"

# docker
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"

# lua
eval "$(luarocks path)"

# openssl (for lua)
export PATH="$PATH:/usr/local/opt/openssl/bin"
export PATH="$PATH:$(brew --prefix openssl)/bin"

# gcloud
if [ -f '/Users/fausto/Google/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/fausto/Google/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/fausto/Google/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/fausto/Google/google-cloud-sdk/completion.zsh.inc'; fi

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
