#!/usr/bin/env bash

usage() {
    cat << EOF
USAGE: ${0##*/} [OPTIONS] PATH

Watches when new image (PNG or JPEG) are added and transform to WebP format

OPTIONS:
    -h, --help          Display this usage message and exit
    -q, --quaity INT    Specify the compression factor between 0-100 (default: 90)
EOF
}

require() {
    command -v "${1}" &>/dev/null && return
    printf '%s\n' "Missing required application: '${1}'" >&2
    return 1
}

run() {
    local file

    set -e

    mkdir --parents "${1}"

    while read -r file; do
        [[ "${file,,}" =~ \.(png|jpe?g)$ ]] || continue

        printf '%s\n' "Converting file '${file}'..."
        if ! cwebp -q "${quality}" -o "${1}/${file%.*}.webp" "${1}/${file}"; then
            printf '%s\n' "Failed to convert file: '${file}'" >&2
        fi
    done < <(inotifywait --monitor --event "create" --event "moved_to" --format '%f' "${1}")
}

main() {
    local opts quality

    quality="90"
    opts="$(getopt \
        --options hq: \
        --longoptions help,quality: \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       usage; return 0;;
            -q | --quality )    quality="${2}"; shift;;
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
    require "cwebp" || return

    run "${1}"
}

main "${@}"
