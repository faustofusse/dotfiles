function __git_ps1 {
    git branch --show-current 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function show_branch {
    git branch --show-current 2> /dev/null
}

function hola {
    b=git branch --show-current 2> /dev/null
    trimmed=${b%\n.*}
    echo $trimmed
}

# prefix
export PS1=" %1~ %# "
