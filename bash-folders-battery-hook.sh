#!/usr/bin/env bash

# --
# Description: Script that launches other scripts in different battery states.
# --
# Cron: * * * * *  bash-folders-battery-hook.sh --folder [folder path]
# --

#cat /sys/class/power_supply/BAT0/capacity

#cat /sys/class/power_supply/BAT0/status

#Discharging
#Charging
#Full

#xrandr --output eDP --brightness 1


# START
set -e

# VARIABLES
PROGNAME=$(basename "$0")
FOLDER_ORIGIN="$2"
LOW_BATTERY=15
HIGH_BATTERY=85

# FUNCTIONS

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Script that launches other scripts in different battery states.
  "discharging" When the battery is in use.
  "charging" When the battery is charging.
  "low" When it reaches the low percentage. Default 15.
  "high" When it reaches the high percentage. Default 85.
  "full" When the battery is full.

Options:
--folder [path]  Folder where the different scripts are located.
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
    inotifywait -m -e create,moved_to --format '%f' "$FOLDER_ORIGIN" |
	while read -r filename; do
	    # Gets the file extension
	    extension="${filename##*.}"
	    # Checks if the extension is in the extension list
	    for ext in "${EXTENSIONS_TO_WATCH[@]}"; do
		if [[ "$ext" = "$extension" ]]; then
		    # Check if the file name starts with "optimized"
		    if [[ "$filename" != optimized* ]]; then
		    	filename_output="optimized_${filename%.*}.mp4"
			# Notifies that the conversion is to be started
			send-notification "Optimizing $filename_output ..."
			# Displays a flat file of information
			touch "$FOLDER_ORIGIN/$MESSAGE_WAITING"
			# Convert the file to MP4 format using ffmpeg in /tmp/
			ffmpeg -i "$FOLDER_ORIGIN/$filename" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -nostdin -shortest "/tmp/$filename_output"
			# When finished move the optimized file
			mv "/tmp/$filename_output" "$FOLDER_ORIGIN/$filename_output"
			# Notifies that it has been terminated
			send-notification "Completed! Output: $filename_output"
			# Remove a flat file of information
			rm "$FOLDER_ORIGIN/$MESSAGE_WAITING"
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
