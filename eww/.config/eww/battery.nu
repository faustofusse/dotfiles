#!/usr/bin/env nu
open /sys/class/power_supply/BAT0/capacity | lines | first | print ($in)%
