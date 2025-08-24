#!/usr/bin/env nu

def menu [title: string, commands: table<title: string, command: closure>] {
    let titles = $commands | get title | to text 
    let selected = $titles | tofi --prompt-text $"($title): "
    let command = $commands | where title == $selected | get command | first
    do $command
}

def main [] {
    menu "menu" [
        { title: "run", command: { || tofi-drun --drun-launch=true } },
        { title: "capture", command: { || capture } },
        { title: "time", command: { || dunstify (date now | format date "%R") } },
        { title: "battery", command: { || dunstify (open /sys/class/power_supply/BAT0/capacity) } },
        { title: "lock", command: { || lock } },
        { title: "shutdown", command: { || shutdown now } },
        { title: "reboot", command: { || reboot } },
    ]
}

def lock [] {
    grim -t jpeg -q 30 ~/.cache/swaylock.jpeg
    swaylock --image ~/.cache/swaylock.jpeg --effect-blur 5x3
}

def screenshot [] {
    let name = date now | format date "%s"
    grim -t png -g (slurp -d) ~/Downloads/($name).png
}

def capture [] {
    menu "capture" [
        { title: "screenshot", command: { || screenshot } },
        { title: "recording", command: { || } },
    ]
}
