#!/bin/bash

SOURCE_ICON="icon.png" # Your master icon, already shaped
OUTPUT_DIR="./"

# Check if the source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
  echo "Error: Source icon '$SOURCE_ICON' not found."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Generating Mac app icons from '$SOURCE_ICON' into '$OUTPUT_DIR'..."

# 16x16 pt
magick "$SOURCE_ICON" -resize 16x16 "$OUTPUT_DIR/MacIcon_16x16.png"
magick "$SOURCE_ICON" -resize 32x32 "$OUTPUT_DIR/MacIcon_16x16@2x.png"

# 32x32 pt
magick "$SOURCE_ICON" -resize 32x32 "$OUTPUT_DIR/MacIcon_32x32.png"
magick "$SOURCE_ICON" -resize 64x64 "$OUTPUT_DIR/MacIcon_32x32@2x.png"

# 128x128 pt
magick "$SOURCE_ICON" -resize 128x128 "$OUTPUT_DIR/MacIcon_128x128.png"
magick "$SOURCE_ICON" -resize 256x256 "$OUTPUT_DIR/MacIcon_128x128@2x.png"

# 256x256 pt
magick "$SOURCE_ICON" -resize 256x256 "$OUTPUT_DIR/MacIcon_256x256.png"
magick "$SOURCE_ICON" -resize 512x512 "$OUTPUT_DIR/MacIcon_256x256@2x.png"

# 512x512 pt (including the 1024x1024 for @2x)
magick "$SOURCE_ICON" -resize 512x512 "$OUTPUT_DIR/MacIcon_512x512.png"
magick "$SOURCE_ICON" -resize 1024x1024 "$OUTPUT_DIR/MacIcon_512x512@2x.png" # This is also your App Store icon

echo "All Mac app icons generated successfully in the '$OUTPUT_DIR' directory."
