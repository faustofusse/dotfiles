# zsh config
ZSH_THEME="common" # robbyrussel, lambda-gitster, typewritten, common, bunnyruni, another, logico, pi
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# autoload -U compinit && compinit
plugins=( git bundler dotenv macos rake rbenv ruby pyenv vi-mode ) # zsh-completions 

# path
# export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"

# openvpn (commented on 02/aug/2022)
export PATH="$PATH:/usr/local/Cellar/openvpn/2.5.8/sbin"

# openai
export OPENAI_API_KEY='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'

# java
export JDTLS_HOME='/Library/Java/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository'
# export JAVA_HOME='/Library/Java/JavaVirtualMachines/jdk-17.0.1.jdk/Contents/Home'
export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home'
# export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home'
export PATH="$PATH:$JAVA_HOME/bin"

# ruby
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
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
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

# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"
# export DOTNET_ROOT="/usr/local/share/dotnet"

# android
# export ANDROID_HOME=/Users/faustofusse/Library/Android/sdk
# export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
# export ANDROID_SDK=$HOME/Library/Android/sdk
# export PATH=$PATH:$ANDROID_SDK/emulator
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

# bun completions
[ -s "/Users/faustofusse/.bun/_bun" ] && source "/Users/faustofusse/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# docker
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"

# lua
eval "$(luarocks path)"

# openssl (for lua)
export PATH="$PATH:/usr/local/opt/openssl/bin"
export PATH="$PATH:$(brew --prefix openssl)/bin"

# aliases
alias lg="lazygit"
alias ts="tmux-sessionizer"
alias v="nvim"
alias ccd="cd \"\$(findproject)\" && clear"
alias tsm="transmission-remote"
alias ctb="clear && tb"
