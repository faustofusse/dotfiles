# TODO: hacer algo con %2 en vez de %1 para los que no son git

# git branch
function git_branch_name() {
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo ' ('$branch')'
  fi
}

# nix direnv
function icon() {
    # direnv_file=$DIRENV_FILE
    # if [[ $direnv_file == "" ]];
    # then
    #     echo '%#'
    # else
    #     echo ''
    # fi
    echo '%#'
}

# Enable substitution in the prompt.
setopt prompt_subst

# Config for prompt. PS1 synonym.
prompt=' %1~$(git_branch_name) $(icon) '
