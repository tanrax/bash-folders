
#!/usr/bin/env bash

# --
# Description: Script that watches when new image (PNG or JPEG) are added and transform to WebP format.
# --
# Requirements: Install webp
# Example Debian: $sudo apt install webp
# --
# Cron: @reboot bash-folders-image-to-webp.sh >/dev/null 2>&1 &
# --

# START
set -e


# FUNCTIONS

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Watches when new image (PNG or JPEG) are added and transform to WebP format.
Options:
--folder [path]  Folder path where will be monitored.
--help           Display this usage message and exit
EOF

    exit 1
}

start() {
    # Output
    cd "$FOLDER_ORIGIN"
    # Monitors the selected folder
    inotifywait -m -e create,moved_to --format '%f' "$FOLDER_ORIGIN" |
	while read -r filename; do
	    # Gets the file extension
	    extension="${filename##*.}"
	    filepath=$(readlink -f "$FOLDER_ORIGIN/$filename")
	    # Checks if the extension is in the extension list
	    for ext in "${EXTENSIONS_TO_WATCH[@]}"; do
		if [[ "$ext" = "$extension" ]]; then
			filename_output="optimized_${filename%.*}.mp4"
		    # Decompresses the file
		    filetype=$(file -b "$filepath" | awk '{print $1}')
		    cwebp -q 90 example.jpeg -o example.webp
		    # Notifies that it has been terminated
		    send-notification "Descompressing $filename finished."
		fi
	    done
	done
}


# CONTROLE ARGUMENTS

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
	--folder)
	    FOLDER_ORIGIN="$2"
	    shift # past argument
	    shift # past value
	    ;;
	--quality)
	    QUALITY="$2"
	    shift # past argument
	    shift # past value
	    ;;
	*)
	    usage "Unknown option: $1"
	    ;;
    esac
done

# VARIABLES
PROGNAME=$(basename "$0")
FOLDER_ORIGIN="$2"
EXTENSIONS_TO_WATCH=("jpg" "jpeg" "png")

# CHECKS

# Check if exists cwebp
if ! which -q cwebp; then
    echo "Error: You must install the WebP terminal tools."
    exit 1

# Check if the required --folder flag is provided
if [ -z "$FOLDER_ORIGIN" ]; then
    echo "Error: The --folder flag is required."
    exit 1
    
start
