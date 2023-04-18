#!/usr/bin/env bash

# --
# Description: Script that watches when new videos are added to a folder and optimizes them.
# --
# Requirements: Install inotify-tools and ffmpeg
# Example Debian: $sudo apt install inotify-tools ffmpeg
# --
# Cron: @reboot dynamic-video-to-mp4.sh >/dev/null 2>&1 &
# --

# START
set -e

# VARIABLES
PROGNAME=$(basename "$0")
FOLDER_ORIGIN="$2"
EXTENSIONS_TO_WATCH=("mkv" "mp4" "avi" "mov")

# FUNCTIONS

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Watches when new videos are added to a folder and optimizes them.
Options:
--folder [path]  Folder path where new video will be monitored and optimized
--help           Display this usage message and exit
EOF

    exit 1
}

send-notification() {
    if command -v notify-send >/dev/null 2>&1; then
	# Send a native notification
	notify-send "$1"
    else
	# If the above command is not available, print by console
	echo "$1"
    fi

}

start() {
    # Monitors the selected folder
    inotifywait -m -e create --format '%f' "$FOLDER_ORIGIN" |
	while read -r filename; do
	    # Gets the file extension
	    extension="${filename##*.}"
	    # Checks if the extension is in the extension list
	    for ext in "${EXTENSIONS_TO_WATCH[@]}"; do
		if [[ "$ext" = "$extension" ]]; then
		    # Check if the file name starts with "optimized"
		    if [[ "$filename" != optimized* ]]; then
			# Notifies that the conversion is to be started
			send-notification "Optimizing $filename ..."
			# Convert the file to MP4 format using ffmpeg
			ffmpeg -i "$FOLDER_ORIGIN/$filename" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -nostdin -shortest "$FOLDER_ORIGIN/optimized_${filename%.*}.mp4"
			# Notifies that it has been terminated
			send-notification "Completed! Output: optimized_${filename%.*}.mp4"
		    fi
		fi
	    done
	done
}

# CONTROLE ARGUMENTS
isArg=""

while [ $# -gt 0 ] ; do
    case "$1" in
    --help)
        usage
        ;;
    --folder)
        isArg="1"
	if [ $# -eq 2 ]; then
	    start
	else
	    usage "You need to specify the path of the folder to watch."
	fi
        ;;
    *)
    esac
    shift
done

if [ -z $isArg ] ; then
    usage "Not enough arguments"
fi
