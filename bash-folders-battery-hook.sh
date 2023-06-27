#!/usr/bin/env bash

set -e

usage() {
    [[ -n "${*}" ]] && printf '%s\n' "Error: ${*}" >&2

    cat << EOF
USAGE: ${0##*/} [OPTION] --folder PATH

Launches other scripts in different battery states

OPTIONS:
    --help              Display this usage message and exit
    --folder PATH       PATH where the different scripts are located
    --low INT           Low battery percentage (default: 15)
    --high INT          High battery percentage (default: 85)

STATES:
    discharching        When the battery is in use
    charging            When the battery is charging
    low                 When the battery reaches the low percentage
    high                When the battery reaches the high percentag
    full                When the battery is full
EOF

    exit 1
}

status() {
    cat /sys/class/power_supply/BAT0/status
}

capacity() {
    cat /sys/class/power_supply/BAT0/capacity
}

run_discharging() {
    if ! [[  -f "$PATH_DISCHARGING_SCRIPT" ]]; then
        touch "$PATH_DISCHARGING_SCRIPT"
        chmod +x "$PATH_DISCHARGING_SCRIPT"
    fi

    if [[ "$(status)" == "Discharging" ]]; then
        $PATH_DISCHARGING_SCRIPT
    fi
}

run_charging() {
    if ! [[ -f "$PATH_CHARGING_SCRIPT" ]]; then
        touch "$PATH_CHARGING_SCRIPT"
        chmod +x "$PATH_CHARGING_SCRIPT"
    fi

    if [[ "$(status)" == "Charging" ]]; then
        $PATH_CHARGING_SCRIPT
    fi
}

run_low() {
    if ! [[ -f "$PATH_LOW_SCRIPT" ]]; then
        touch "$PATH_LOW_SCRIPT"
        chmod +x "$PATH_LOW_SCRIPT"
    fi

    if [[ "$(status)" == "Discharging" ]] && [[ "$(capacity)" -le "$LOW_BATTERY" ]]; then
        $PATH_LOW_SCRIPT
    fi
}

run_high() {
    if ! [[ -f "$PATH_HIGH_SCRIPT" ]]; then
        touch "$PATH_HIGH_SCRIPT"
        chmod +x "$PATH_HIGH_SCRIPT"
    fi

    if [[ "$(status)" == "Charging" ]] && [[ "$(capacity)" -ge "$HIGH_BATTERY" ]]; then
        $PATH_HIGH_SCRIPT
    fi
}

run_full() {
    if ! [[ -f "$PATH_FULL_SCRIPT" ]]; then
        touch "$PATH_FULL_SCRIPT"
        chmod +x "$PATH_FULL_SCRIPT"
    fi

    if [[ "$(status)" = "Full" ]]; then
        $PATH_FULL_SCRIPT
    fi
}

start() {
    run_discharging
    run_charging
    run_low
    run_high
    run_full
}

while [[ $# -gt 0 ]]; do
    case "${1}" in
    --folder)
        FOLDER_ORIGIN="$2"
        shift 2
        ;;
    --low)
        LOW_BATTERY="$2"
        shift 2
        ;;
    --high)
        HIGH_BATTERY="$2"
        shift 2
        ;;
    *)
        usage "Unknown option: $1"
        ;;
    esac
done

LOW_BATTERY=20
HIGH_BATTERY=80
DISCHARGING_SCRIPT="discharging"
PATH_DISCHARGING_SCRIPT="$FOLDER_ORIGIN/$DISCHARGING_SCRIPT"
CHARGING_SCRIPT="charging"
PATH_CHARGING_SCRIPT="$FOLDER_ORIGIN/$CHARGING_SCRIPT"
LOW_SCRIPT="low"
PATH_LOW_SCRIPT="$FOLDER_ORIGIN/$LOW_SCRIPT"
HIGH_SCRIPT="high"
PATH_HIGH_SCRIPT="$FOLDER_ORIGIN/$HIGH_SCRIPT"
FULL_SCRIPT="full"
PATH_FULL_SCRIPT="$FOLDER_ORIGIN/$FULL_SCRIPT"

if [[ -z "$FOLDER_ORIGIN" ]]; then
    printf '%s\n' "Error: The --folder flag is required" >&2
    exit 1
else
    start
fi
