#!/bin/bash

# List of video URIs
videos=("https://cdn.hallads.com/sample7.mp4" "https://cdn.hallads.com/admin/10sdku5v.mp4")

# Function to play a video
play_video() {
    uri=$1
    gst-launch-1.0 playbin uri=$uri
}

# Loop through the videos indefinitely
while true; do
    for video in "${videos[@]}"; do
        play_video $video
    done
done
