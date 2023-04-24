python3 -m ffpb -threads 1 -i $1 -c:v libx265 -c:a copy -crf 28 -vtag hvc1 $2
# -filter:v fps=60

