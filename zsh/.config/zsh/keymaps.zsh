bindkey '^[[A' history-substring-search-up # or '\eOA'
bindkey '^[[B' history-substring-search-down # or '\eOB'

bindkey -v
bindkey ^R history-incremental-search-backward 
bindkey ^S history-incremental-search-forward
bindkey ^P up-line-or-search
bindkey ^N down-line-or-search
