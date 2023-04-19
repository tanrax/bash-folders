#!/usr/bin/env bash

# --
# Description: Script that decompresses all the files that are left in the folder.
# --nnnnnnn
# Requirements: Install inotify-tools, gzip bzip2 xz-utils unzip p7zip-full and unrar
# Example Debian: $sudo apt install inotify-tools gzip bzip2 xz-utils unzip p7zip-full unrar
# --
# Cron: @reboot bash-folders-descompress.sh >/dev/null 2>&1 &
# --

# START
set -e

# EXPORTS
# Fix: notify-send command doesn't launch the notification through systemd service
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${UID}/bus}"

# VARIABLES
PROGNAME=$(basename "$0")
FOLDER_ORIGIN="$2"
EXTENSIONS_TO_WATCH=("gzip" "bzip2" "xz" "zip" "7z" "rar")

# FUNCTIONS

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Watches new compress files and decompresses all the files.
Options:
--folder [path]  Folder path where will be monitored.
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
	    filepath=$(readlink -f "$FOLDER_ORIGIN/$filename")
	    # Checks if the extension is in the extension list
	    for ext in "${EXTENSIONS_TO_WATCH[@]}"; do
		if [[ "$ext" = "$extension" ]]; then
		    # Notifies that the conversion is to be started
		    send-notification "Descompressing '$filename', please wait."
		    # Decompresses the file
		    filetype=$(file -b "$filepath" | awk '{print $1}')
		    case "$filetype" in
			"gzip")
			    gzip -d "$filepath"
			    ;;
			"bzip2")
			    bzip2 -d "$filepath"
			    ;;
			"XZ")
			    xz -d "$filepath"
			    ;;
			"Zip")
			    unzip "$filepath"
			    ;;
			"7-zip")
			    7z x "$filepath"
			    ;;
			"RAR")
			    unrar x "$filepath"
			    ;;
			*)
			    send-notification "Error: Unknown file type $filetype"
			    ;;
		    esac
		    # Notifies that it has been terminated
		    send-notification "Descompressing $filename finished."
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
