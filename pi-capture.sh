#!/bin/bash

set -e

DEST_PATH="${1:-$DEST_PATH}"

if [ -z "$DEST_PATH" ]; then
  echo "Error: No destination path provided."
  echo "Usage: ./pi-capture.sh /path/to/frames"
  exit 1
fi

# Ensure destination exists
mkdir -p "$DEST_PATH"

# Output path
TEMP_FILE="/tmp/frame.jpg"
DEST_FILE="$DEST_PATH/frame.jpg"

# Use V4L2 device — usually /dev/video0 on Pi
VIDEO_DEVICE="/dev/video0"

# Capture a single frame
echo "📸 Capturing frame from $VIDEO_DEVICE..."
ffmpeg -hide_banner -loglevel error \
  -f v4l2 -video_size 640x480 -i "$VIDEO_DEVICE" \
  -vframes 1 "$TEMP_FILE"

if [ ! -f "$TEMP_FILE" ]; then
  echo "❌ Frame not captured!"
  exit 1
fi

mv "$TEMP_FILE" "$DEST_FILE"
echo "✅ Frame saved to: $DEST_FILE"