#!/usr/bin/env bash

ffpb.sh -y -i "$1" -c:v libx265 -c:a aac -crf 26 "$2"
# -reset_timestamps 1
# -threads 1
# -filter:v fps=60
