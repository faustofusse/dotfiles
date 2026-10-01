if you need to install programs try to use nix first (be it in a shell, the project's flake, or the nix profile). if you can't then use another method
if you need to run a process to test something (for example a server / api) and you are inside herdr use the herdr skill to run that process in a different pane
if you need a container use apple's containers cli instead of docker when possible. if you need compose use docker
if you need to commit something use prefixes like 'feat: ', 'fix: ', 'chore: ', ...
