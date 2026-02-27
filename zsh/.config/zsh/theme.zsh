# TODO: hacer algo con %2 en vez de %1 para los que no son git

# git branch
function git_branch_name() {
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '%F{238}:%f'$branch''
  fi
}

# nix direnv
function icon() {
    if [[ $IN_NIX_SHELL == "" ]];
    then
        echo '$'
    else
        echo '' # #7EBAE4
    fi
}

# Enable substitution in the prompt.
setopt prompt_subst

# Config for prompt. PS1 synonym.
prompt=' %~$(git_branch_name) $(icon) '
