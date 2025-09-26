#!/bin/bash

# Version handling
VERSION="__VERSION__" # This will be replaced during build

# Handle version arguments
case "${1:-}" in
--version | -v | version)
	echo "battery-full-alert $VERSION"
	exit 0
	;;
--help | -h | help)
	echo "Usage: battery-full-alert [--version|-v|version] [--help|-h|help]"
	echo "Monitor battery and send notifications when fully charged."
	exit 0
	;;
esac

# Load configuration
CONFIG_FILE="$HOME/.config/battery-full-alert.conf"
if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

# Default values if not set in config
THRESHOLD=${THRESHOLD:-95}
SOUND_FILE=${SOUND_FILE:-/usr/share/sounds/freedesktop/stereo/complete.oga}
ENABLE_SOUND=${ENABLE_SOUND:-true}

BATTERY=$(upower -e | grep 'BAT\|battery' | head -1)

# Exit if no battery found
if [ -z "$BATTERY" ]; then
	exit 0
fi

STATE=$(upower -i "$BATTERY" | awk '/state/ {print $2}')
PERCENT=$(upower -i "$BATTERY" | awk '/percentage/ {print $2}' | tr -d '%')

mkdir -p "$HOME/.cache"

# Create a flag file to avoid repeated notifications
FLAG_FILE="$HOME/.cache/battery-full-notified"

if { [ "$STATE" = "charging" ] || [ "$STATE" = "fully-charged" ]; } && [ "$PERCENT" -ge "$THRESHOLD" ]; then
	# Only notify if we haven't already notified for this charging session
	if [ ! -f "$FLAG_FILE" ]; then
		notify-send -a "Battery Watcher" -u normal -i battery "⚡️ Battery Alert" "Battery is at ${PERCENT}% and fully charged!"

		# Play sound if enabled and file exists
		if [ "$ENABLE_SOUND" = "true" ] && [ -f "$SOUND_FILE" ]; then
			paplay "$SOUND_FILE" &
		fi

		touch "$FLAG_FILE"
	fi
else
	# Remove flag when battery drops below threshold or unplugged
	[ -f "$FLAG_FILE" ] && rm "$FLAG_FILE"
fi
