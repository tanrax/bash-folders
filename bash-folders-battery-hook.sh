#!/usr/bin/env bash

usage() {
    cat << EOF
USAGE: ${0##*/} [OPTIONS] PATH

Launches other scripts for different battery states

OPTIONS:
    -h, --help          Display this usage message and exit
    -l, --low INT       Low battery percentage (default: ${defaults['low']})
    -h, --high INT      High battery percentage (default: ${defaults['high']})
    -b, --battery INT   Battery to be checked

STATE SCRIPTS:
    discharching        When the battery is in use
    charging            When the battery is charging
    low                 When the battery reaches the low percentage
    high                When the battery reaches the high percentag
    full                When the battery is full
EOF
}

run() {
    set -e

    local status capacity
    status="$(< "/sys/class/power_supply/BAT${settings['battery']}/status")"
    capacity="$(< "/sys/class/power_supply/BAT${settings['battery']}/capacity")"

    case "${status,,}" in
        discharging )
            "${1}/${status,,}"
            if (( capacity <= settings['low'] )); then
                "${1}/low"
            fi
            ;;
        charging )
            "${1}/${status,,}"
            if (( capacity >= settings['high'] )); then
                "${1}/high"
            fi
            ;;
        full )
            "${1}/high"
            "${1}/${status,,}"
            ;;
    esac

    return 0
}

main() {
    local -A defaults settings
    local opts i

    opts="$(getopt \
        --options hl:H:b: \
        --longoptions help,low:,high:,battery: \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    defaults['low']="15"
    defaults['high']="85"
    defaults['battery']="0"
    for i in "${!defaults[@]}"; do settings["$i"]="${defaults["$i"]}"; done

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       usage; return 0;;
            -l | --low )        settings['low']="${2}"; shift;;
            -H | --high )       settings['high']="${2}"; shift;;
            -b | --battery )    settings['battery']="${2}"; shift;;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    if [[ -z "${1}" ]]; then
        printf '%s\n' "No folder specified" >&2
        return 1
    fi

    mkdir --parents "${1}"
    for i in "charging" "discharging" "full" "low" "high"; do
        touch -a "${1}/${i}"
        chmod +x "${_}"
    done

    run "${1}"
}

main "${@}"
