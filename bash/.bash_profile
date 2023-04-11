export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/Users/faustofusse/.local/bin"

export ANDROID_HOME=/Users/faustofusse/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK/emulator:$PATH

export JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home'

export PATH="$JAVA_HOME/bin:$PATH"
export PATH="/usr/local/opt/ncurses/bin:$PATH"

export NODE_PATH=$HOME/.npm/lib/node_modules
export PATH=$PATH:$HOME/.npm/bin


# MacPorts Installer addition on 2019-12-09_at_14:52:45: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

if [ $ITERM_SESSION_ID ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi

# Aliases
# Establishing custom commands below
alias bash_profile="open ~/.bash_profile"
alias ffpb="python -m ffpb"
alias stopvshield="sudo /usr/local/McAfee/AntiMalware/VSControl stopoas" 
alias himym="python ~/Documents/Software/Python/himym.py"
alias ghci="stack ghci"

export PATH="$PATH:/Users/faustofusse"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
. "$HOME/.cargo/env"

