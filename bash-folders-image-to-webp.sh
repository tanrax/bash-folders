#!/usr/bin/env bash

set -e

usage() {
    [[ -n "${*}" ]] && printf '%s\n' "Error: ${*}" >&2

    cat << EOF
USAGE: ${0##*/} [OPTION] --folder PATH

Watches when new image (PNG or JPEG) are added and transform to WebP format

OPTIONS:
    --help              Display this usage message and exit
    --folder PATH       PATH to be monitored
EOF

    exit 1
}

start() {
    inotifywait -m -e create,moved_to --format '%f' "$FOLDER_ORIGIN" | while read -r filename; do
        extension="${filename##*.}"
        for ext in "${EXTENSIONS_TO_WATCH[@]}"; do
            if [[ "$ext" == "$extension" ]]; then
                filename_output="${filename%.*}.webp"
                touch "$FOLDER_ORIGIN/$MESSAGE_WAITING"
                cwebp -q "$QUALITY" "$FOLDER_ORIGIN/$filename" -o "$FOLDER_ORIGIN/$filename_output"
                rm "$FOLDER_ORIGIN/$MESSAGE_WAITING"
            fi
        done
    done
}

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
    --folder)
        FOLDER_ORIGIN="$2"
        shift 2
        ;;
    --quality)
        QUALITY="$2"
        shift 2
        ;;
    *)
        usage "Unknown option: $1"
        ;;
    esac
done

QUALITY="90"
MESSAGE_WAITING="converting_please_wait"
EXTENSIONS_TO_WATCH=("jpg" "jpeg" "png")

if ! command -v cwebp > /dev/null; then
	printf '%s\n' "Error: You must install WebP tooling" >&2
    exit 1
fi

# Check if the required --folder flag is provided
if [[ -z "$FOLDER_ORIGIN" ]]; then
	printf '%s\n' "Error: The --folder flag is required" >&2
    exit 1
fi

start
