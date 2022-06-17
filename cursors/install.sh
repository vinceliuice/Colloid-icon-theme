#!/bin/bash

ROOT_UID=0
DEST_DIR=
THEME_NAME=Colloid

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

if [ -d "$DEST_DIR/$THEME_NAME-cursors" ]; then
  rm -r "$DEST_DIR/$THEME_NAME-cursors"
fi

if [ -d "$DEST_DIR/$THEME_NAME-dark-cursors" ]; then
  rm -r "$DEST_DIR/$THEME_NAME-dark-cursors"
fi

cp -r dist "$DEST_DIR/$THEME_NAME-cursors"
cp -r dist-dark "$DEST_DIR/$THEME_NAME-dark-cursors"

echo "Finished..."

