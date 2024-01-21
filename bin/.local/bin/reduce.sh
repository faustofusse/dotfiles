python3 -m ffpb -i $1 -c:v libx265 -c:a aac -crf 25 -tag:v hvc1 $2
# -reset_timestamps 1
# -threads 1
# -filter:v fps=60
