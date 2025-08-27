#!/usr/bin/env nu

def menu [title: string, commands: table<title: string, command: closure>] {
    let titles = $commands | get title | to text 
    let selected = $titles | tofi --prompt-text $"($title): " --num-results 10
    let command = $commands | where title == $selected | get command | first
    do $command
}

def main [] {
    menu "system" [
        { title: "run", command: { || tofi-drun --drun-launch=true } },
        { title: "capture", command: { || capture } },
        { title: "time", command: { || dunstify (date now | format date "%R") } },
        { title: "battery", command: { || dunstify (open /sys/class/power_supply/BAT0/capacity | lines | first)% } },
        { title: "wifi", command: { || ghostty --initial-command=nmtui --title=settings } },
        { title: "bluetooth", command: { || ghostty --initial-command=bluetui --title=settings } },
        { title: "sound", command: { || ghostty --initial-command=wiremix --title=settings } },
        { title: "lock", command: { || lock } },
        { title: "shutdown", command: { || shutdown now } },
        { title: "reboot", command: { || reboot } },
    ]
}

def pick [] {
    let color = grim -g (slurp -p) -t ppm - | magick - txt:- | lines | split row ' ' | get 8
    $color | wl-copy
    dunstify $color
}

def lock [] {
    grim -t jpeg -q 30 ~/.cache/swaylock.jpeg
    swaylock --image ~/.cache/swaylock.jpeg --effect-blur 5x3
}

def "screenshot edit" [] {
    let name = date now | format date "%+"
    grim -t png -g (slurp -d) - | satty --filename - --output-filename ~/Downloads/($name).png --no-window-decoration
}

def "screenshot save" [] {
    let name = date now | format date "%+"
    grim -t png -g (slurp -d) ~/Downloads/($name).png
    dunstify "screenshot saved!"
}

def "screenshot copy" [] {
    grim -t png -g (slurp -d) - | wl-copy
    dunstify "screenshot copied!"
}

def capture [] {
    menu "capture" [
        { title: "screenshot (copy)", command: { || screenshot copy } },
        { title: "screenshot (save)", command: { || screenshot save } },
        { title: "screenshot (edit)", command: { || screenshot edit } },
        { title: "color", command: { || pick } },
        { title: "recording", command: { || } },
    ]
}
