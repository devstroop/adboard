#!/bin/bash

# Function to play the next advertisement
play_advertisement() {
    local uri="$1"
    gst-launch-1.0 playbin uri="$uri"
}

# Function to fetch advertisements from the server
fetch_ads() {
    local url="http://doohfy.com/odata/DOOHDB/Advertisements"
    curl -s "$url" | jq -r '.value[].AttachmentKey' || echo ""
}

# Main loop
while true; do
    # Fetch advertisements
    ads=$(fetch_ads)

    # Check if ads are fetched successfully
    if [ -z "$ads" ]; then
        echo "Error fetching advertisements"
        continue
    fi

    # Play each advertisement
    for ad in $ads; do
        uri="https://cdn.hallads.com/$ad"
        echo "Playing advertisement: $uri"
        play_advertisement "$uri"
    done
done
