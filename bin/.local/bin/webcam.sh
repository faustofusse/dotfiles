mpv av://avfoundation:0:none --demuxer-lavf-o=video_size=1920x1080  --demuxer-lavf-o=framerate=30 --demuxer-force-retry-on-eof=yes
# to list devices: ffmpeg -f avfoundation -list_devices true -i ""
