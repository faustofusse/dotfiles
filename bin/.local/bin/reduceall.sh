#!/bin/bash
for f in *
do
    reduce.sh "$f" "$f".mp4
done
