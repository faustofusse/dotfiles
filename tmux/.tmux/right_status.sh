#!/bin/bash

function cpu() {
    printf "cpu: %s" "$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}')"
}

function current_song() {
    printf "#[fg=default]♫ #[fg=default]%s" "$(~/.tmux/spotify-macos.sh info | sed 's/^.*:\ *//g;/^$/d;s/$/;/g' | xargs echo | awk -F "; " '{printf("%s - %s", $2, $1)}' | sed 's/;//g')"
}

function main() {
    if [ "$(~/.tmux/spotify-macos.sh isrunning)" == "true" ]; then
        current_song
    else
        cpu
    fi
}

main
