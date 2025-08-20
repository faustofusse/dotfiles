#!/usr/bin/env bash

# Set the directory to the first argument or the current directory if not provided
DIR="${1:-.}"

# Find all video files in the directory and its subdirectories
find "$DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) | while read -r file; do
    # Check if the video is not h265
    if ! ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" | grep -q "hevc"; then
        # If it's not h265, call reduce.sh on it
        echo "Reducing $file"
        reduce.sh "$file"
    else
        echo "Skipping $file"
    fi
done
