ffmpeg -i $1 -metadata title="$2" -c copy temp.mp4 && rm $1 && mv temp.mp4 $1
