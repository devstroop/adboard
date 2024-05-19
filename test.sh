#!/bin/bash

# List of video URIs
videos=("https://cdn.hallads.com/admin/ftdk4t35.mp4" "https://cdn.hallads.com/admin/eedqsd1c.mp4" "https://cdn.hallads.com/admin/dcngbihx.mp4")

# Function to play a video
play_video() {
    uri=$1
    echo "Playing video: $uri"
    gst-launch-1.0 uridecodebin uri=$uri ! videoconvert ! videoflip method=counterclockwise ! autovideosink
    if [ $? -ne 0 ]; then
        echo "Failed to play video: $uri" >&2
    fi
}

# Loop through the videos indefinitely
while true; do
    for video in "${videos[@]}"; do
        play_video $video
    done
done
