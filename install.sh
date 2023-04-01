#!/bin/bash
AIRCRAFT_DIR="$1"
SRC_DIR="$(dirname "$0")"

if [ "$AIRCRAFT_DIR" == "" ]
then
    echo "Please specify an aircraft directory."
fi

rsync -r "$SRC_DIR/Nasal/html/" "$AIRCRAFT_DIR/Nasal/html/"
