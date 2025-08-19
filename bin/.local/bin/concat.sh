#!/usr/bin/env bash

# example file:
# file '/Users/faustofusse/Desktop/1.mp4'
# file '/Users/faustofusse/Desktop/2.mp4'
# file '/Users/faustofusse/Desktop/3.mp4'
# file '/Users/faustofusse/Desktop/4.mp4'

# video_track_timescale es el tbn del video (ffprobe)
# ar son los Hz del audio (ffprobe)
# -c:v copy -video_track_timescale 30k -c:a aac -ac 6 -ar 44100 -shortest
# -c:v copy -video_track_timescale 24k -c:a aac -ac 6 -ar 48000 -shortest

ffmpeg -f concat -safe 0 -i $1 -c copy $2
