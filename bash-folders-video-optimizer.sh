#!/usr/bin/env bash

usage() {
    cat << EOF
USAGE: ${0##*/} [OPTION] PATH

Watches when new videos are added to a folder and optimizes them.

OPTIONS:
    --help          Display this usage message and exit
EOF
}

require() {
    command -v "${1}" &>/dev/null && return
    printf '%s\n' "Missing required application: '${1}'" >&2
    return 1
}

optimize() {
    touch -a "${2}"
    ffmpeg \
        -i "${1}" \
        -c:v "libx264" \
        -tune stillimage \
        -c:a "aac" \
        -b:a "192k" \
        -pix_fmt "yuv420p" \
        -nostdin \
        -shortest \
        "${2}"
}

run() {
    local file

    set -e

    mkdir --parents "${1}/optimized"

    while read -r file; do
        [[ "${file,,}" =~ \.(avi|m(kv|p4|ov))$ ]] || continue

        printf '%s\n' "Optimizing file '${file}'..."
        if ! optimize "${file}" "${1}/optimized/${file%.*}.mp4"; then
            printf '%s\n' "Failed to optimize file: '${file}'" >&2
        fi
    done < <(inotifywait --monitor --event "create" --event "moved_to" --format '%f' "${1}")
}

main() {
    local opts

    opts="$(getopt \
        --options h \
        --longoptions help \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       usage; return 0;;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    if [[ -z "${1}" ]]; then
        printf '%s\n' "No folder specified" >&2
        return 1
    fi

    require "inotifywait" || return
    require "ffmpeg" || return

    mkdir --parents "${1}"
    run "${1}"
}

main "${@}"
