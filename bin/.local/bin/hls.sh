#!/usr/bin/env bash

ffmpeg -i "$1" -c copy -bsf:a aac_adtstoasc "$2"
