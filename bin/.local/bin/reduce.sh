#!/usr/bin/env bash

# -reset_timestamps 1
# -threads 1
# -filter:v fps=60

mv "$1" "$1.bak" && ffpb.sh -y -i "$1.bak" -c:v libx265 -c:a aac -crf 26 "$1" || mv "$1.bak" "$1"
