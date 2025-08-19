#!/bin/bash

# ffpb.sh - A ffmpeg wrapper to show progress percentage.

# Function to show usage
usage() {
    echo "Usage: ffpb.sh [ffmpeg options]"
    echo "A wrapper for ffmpeg that shows a progress bar."
    echo "It requires the '-i' option to be present to determine the duration."
}

# Find the input file from the arguments to calculate total duration
input_file=""
args=("$@")
for i in "${!args[@]}"; do
    if [[ "${args[$i]}" == "-i" ]]; then
        input_file="${args[$i+1]}"
        break
    fi
done

if [ -z "$input_file" ]; then
    echo "Error: Input file not specified with -i." >&2
    usage
    exit 1
fi

if [ ! -f "$input_file" ] && ! [[ "$input_file" =~ ^(http|https|rtmp):// ]]; then
    echo "Error: Input file not found or is not a stream: $input_file" >&2
    exit 1
fi

# Get total duration of the input file in seconds using ffprobe
duration_secs=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")

if [ -z "$duration_secs" ]; then
    echo "Warning: Could not determine the duration of the input file." >&2
    echo "Running ffmpeg without a progress bar."
    ffmpeg "$@"
    exit $?
fi

# Create temporary files for progress and logs
PROGRESS_FILE=$(mktemp)
LOG_FILE=$(mktemp)

# Cleanup the temporary files on exit
trap 'rm -f "$PROGRESS_FILE" "$LOG_FILE"' EXIT

# Run ffmpeg in the background, redirecting progress and output
ffmpeg -progress "$PROGRESS_FILE" "$@" >"$LOG_FILE" 2>&1 &
FFMPEG_PID=$!

echo "Starting ffmpeg (PID: $FFMPEG_PID)..."

# Monitor the progress
while kill -0 $FFMPEG_PID 2>/dev/null; do
    # Get the latest progress info from the temp file
    progress_data=$(tail -n 12 "$PROGRESS_FILE")
    out_time_us=$(echo "$progress_data" | grep "out_time_us=" | tail -n 1 | cut -d= -f2)

    if [ -n "$out_time_us" ]; then
        # Calculate percentage
        current_secs=$(echo "$out_time_us / 1000000" | bc -l)
        percentage=$(awk -v current="$current_secs" -v total="$duration_secs" 'BEGIN { printf "%.0f", (current/total)*100 }')
        
        # Display the progress percentage, overwriting the line
        printf "Progress: [%3d%%]\r" "$percentage"
    fi
    sleep 1
done

# Wait for ffmpeg to finish and get its exit code
wait $FFMPEG_PID
EXIT_CODE=$?

# Final progress update to 100% on success
if [ $EXIT_CODE -eq 0 ]; then
    printf "Progress: [100%%]\nDone.\n"
else
    printf "\nffmpeg failed with exit code %d.\n" "$EXIT_CODE"
    echo "--- FFMPEG LOG ---"
    cat "$LOG_FILE"
    echo "------------------"
fi

exit $EXIT_CODE
