#!/usr/bin/env bash

# Combined reduce script - handles both files and directories
# Usage: reduce.sh [file|directory]

# Set the target to the first argument or current directory if not provided
TARGET="${1:-.}"

# Function to reduce a single file
reduce_file() {
    local file="$1"
    echo "Reducing file: $file"
    mv "$file" "$file.bak" && ffpb.sh -y -i "$file.bak" -c:v libx265 -c:a aac -crf 26 "$file" || mv "$file.bak" "$file"
}

# Function to reduce all video files in a directory
reduce_directory() {
    local dir="$1"
    echo "Processing directory: $dir"
    
    # Find all video files in the directory and its subdirectories
    find "$dir" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) | while read -r file; do
        # Check if the video is not h265
        if ! ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" | grep -q "hevc"; then
            # If it's not h265, reduce it
            echo "Reducing $file"
            reduce_file "$file"
        else
            echo "Skipping $file (already H.265)"
        fi
    done
}

# Main logic - determine if target is file or directory
if [[ -f "$TARGET" ]]; then
    # It's a file - reduce it directly
    reduce_file "$TARGET"
elif [[ -d "$TARGET" ]]; then
    # It's a directory - process all video files
    reduce_directory "$TARGET"
else
    echo "Error: '$TARGET' is neither a file nor a directory"
    echo "Usage: $0 [file|directory]"
    exit 1
fi
