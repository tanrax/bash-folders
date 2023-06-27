#!/usr/bin/env bash

set -e

FOLDER_ORIGIN="$2"
EXTENSIONS_TO_WATCH=("mkv" "mp4" "avi" "mov")
MESSAGE_WAITING="optimizing_please_wait"

usage() {
    [[ -n "${*}" ]] && printf '%s\n' "Error: ${*}" >&2

    cat << EOF
USAGE: ${0##*/} [OPTION] --folder PATH

Watches when new videos are added to a folder and optimizes them.

OPTIONS:
    --help          Display this usage message and exit
    --folder PATH   Folder path where new video will be monitored and optimized
EOF

    exit 1
}

start() {
    inotifywait -m -e create,moved_to --format '%f' "$FOLDER_ORIGIN" | while read -r filename; do
        extension="${filename##*.}"
        for ext in "${EXTENSIONS_TO_WATCH[@]}"; do
            if [[ "$ext" = "$extension" ]]; then
                if [[ "$filename" != optimized* ]]; then
                    filename_output="optimized_${filename%.*}.mp4"
                    touch "$FOLDER_ORIGIN/$MESSAGE_WAITING"
                    ffmpeg -i "$FOLDER_ORIGIN/$filename" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -nostdin -shortest "/tmp/$filename_output"
                    mv "/tmp/$filename_output" "$FOLDER_ORIGIN/$filename_output"
                    rm "$FOLDER_ORIGIN/$MESSAGE_WAITING"
                fi
            fi
        done
    done
}

isArg=""

while [[ $# -gt 0 ]]; do
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

if [[ -z "${isArg}" ]]; then
    usage "Not enough arguments"
fi
