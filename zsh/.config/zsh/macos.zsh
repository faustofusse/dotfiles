# user configuration
# export MANPATH="$PATH:/usr/local/man"
# export LDFLAGS="-L/usr/local/opt/zlib/lib"
# export CPPFLAGS="-I/usr/local/opt/zlib/include"
# export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
export LANG=en_US.UTF-8

# bin
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"

# homebrew
export PATH="/opt/homebrew/bin:$PATH"

# nix
#if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
#  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
#else 
#  echo 'nix script not found'
#fi

# nix
export PATH="$PATH:/nix/var/nix/profiles/default/bin"
export PATH="$PATH:$HOME/.nix-profile/bin"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# openvpn (commented on 02/aug/2022)
export PATH="$PATH:/usr/local/Cellar/openvpn/2.5.8/sbin"

# dart
export PATH="$PATH":"$HOME/.pub-cache/bin"

# rust
# source "$HOME/.cargo/env"
export PATH="$PATH:$HOME/.cargo/bin"

# solana
export PATH="/Users/fausto/.local/share/solana/install/active_release/bin:$PATH"

# java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home"
export PATH="$PATH:$JAVA_HOME/bin"

# android
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# ruby
eval "$(rbenv init - zsh)"
# export PATH="$PATH:$HOME/.rvm/bin"

# golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# docker
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"

# direnv
eval "$(direnv hook zsh)"

# # clangd (si lo descomento rompe los 'pod install')
# export PATH="$PATH:/usr/local/opt/llvm/bin"
# export LDFLAGS="-L/usr/local/opt/llvm/lib"
# export CPPFLAGS="-I/usr/local/opt/llvm/include"

# # lua
# eval "$(luarocks path)"

# # openssl (for lua)
# export PATH="$PATH:/usr/local/opt/openssl/bin"
# export PATH="$PATH:$(brew --prefix openssl)/bin"

# # ESP8266
# export IDF_PATH=~/esp/ESP8266_RTOS_SDK
# export PATH="$PATH:$HOME/esp/ESP8266_RTOS_SDK/xtensa-lx106-elf/bin"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# [ -s "/Users/fausto/.bun/_bun" ] && source "/Users/fausto/.bun/_bun"

# # pyenv
# eval "$(pyenv init -)" 
# eval "$(pyenv virtualenv-init -)"
# export PYENV_VIRTUALENV_DISABLE_PROMPT=2
# export BASE_PROMPT=$PS1
# function updatePrompt {
#     if [[ "$(pyenv version-name)" != "system" ]]; then
#         # the next line should be double quote; single quote would not work for me
#         export PS1="($(pyenv version-name)) "$BASE_PROMPT 
#     else
#         export PS1=$BASE_PROMPT
#     fi
# }
# export PROMPT_COMMAND='updatePrompt'
# precmd() { eval '$PROMPT_COMMAND' } # this line is necessary for zsh

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/fausto/.lmstudio/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
