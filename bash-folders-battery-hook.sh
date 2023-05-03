#!/usr/bin/env bash

# --
# Description: Script that launches other scripts in different battery states.
# --
# Cron: * * * * *  bash-folders-battery-hook.sh --folder [folder path]
# --

# START
set -e

# VARIABLES
PROGNAME=$(basename "$0")
FOLDER_ORIGIN="$2"
LOW_BATTERY=15
HIGH_BATTERY=85
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
  "low" When it reaches the low percentage.
  "high" When it reaches the high percentage.
  "full" When the battery is full.

Options:
--folder [path]  Folder where the different scripts are located.
--low [number]   Low battery percentage. Default 15.
--high [number]  High battery percentage. Default 85.
--help           Display this usage message and exit
EOF

    exit 1
}

status() {
    # Possible values: Discharging, Charging and Full
    cat /sys/class/power_supply/BAT0/status
}

capacity() {
    # Possible values: 0-100
    cat /sys/class/power_supply/BAT0/capacity
}

run_discharging() {
    # Check if discharging script exists
    if [ ! -f $PATH_DISCHARGING_SCRIPT ]; then
	# If not, create it
	touch $PATH_DISCHARGING_SCRIPT
	chmod +x $PATH_DISCHARGING_SCRIPT
    fi
    # If status is discharging, run discharging script
    if [ $(status) = "Discharging" ]; then
	$PATH_DISCHARGING_SCRIPT
    fi
}

run_charging() {
    # Check if charging script exists
    if [ ! -f $PATH_CHARGING_SCRIPT ]; then
	# If not, create it
	touch $PATH_CHARGING_SCRIPT
	chmod +x $PATH_CHARGING_SCRIPT
    fi
    # If status is charging, run charging script
    if [ $(status) = "Charging" ]; then
	$PATH_CHARGING_SCRIPT
    fi
}

run_low() {
    # Check if low script exists
    if [ ! -f $PATH_LOW_SCRIPT ]; then
	# If not, create it
	touch $PATH_LOW_SCRIPT
	chmod +x $PATH_LOW_SCRIPT
    fi
    # If status is discharging and battery is low, run low script
    if [ $(status) = "Discharging" ] && [ $(capacity) -le $LOW_BATTERY ]; then
	$PATH_LOW_SCRIPT
    fi
}

run_high() {
    # Check if high script exists
    if [ ! -f $PATH_HIGH_SCRIPT ]; then
	# If not, create it
	touch $PATH_HIGH_SCRIPT
	chmod +x $PATH_HIGH_SCRIPT
    fi
    # If status is charging and battery is high, run high script
    if [ $(status) = "Charging" ] && [ $(capacity) -ge $HIGH_BATTERY ]; then
	$PATH_HIGH_SCRIPT
    fi
}

run_full() {
    # Check if full script exists
    if [ ! -f $PATH_FULL_SCRIPT ]; then
	# If not, create it
	touch $PATH_FULL_SCRIPT
	chmod +x $PATH_FULL_SCRIPT
    fi
    # If status is charging and battery is full, run full script
    if [ $(status) = "Full" ]; then
	$PATH_FULL_SCRIPT
    fi
}

start() {
    # Run all scripts
    run_discharging
    run_charging
    run_low
    run_high
    run_full
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
	    usage "You need to specify the path of different scripts are located."
	fi
        ;;
    --low)
	if [ $# -eq 2 ]; then
	    LOW_BATTERY=$2
	fi
	;;
    --high)
	if [ $# -eq 2 ]; then
	    HIGH_BATTERY=$2
	fi
	;;
    *)
    esac
    shift
done

if [ -z $isArg ] ; then
    usage "Not enough arguments"
fi
