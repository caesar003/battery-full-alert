#!/bin/bash
set -e

echo "Installing Battery Full Alert..."

# Check dependencies
for cmd in upower notify-send paplay; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Error: $cmd is not installed. Please install it first."
		exit 1
	fi
done

# Create directories
mkdir -p ~/.local/bin ~/.config/systemd/user ~/.config

# Install binary (rename from .sh)
cp src/battery-full-alert.sh ~/.local/bin/battery-full-alert
chmod +x ~/.local/bin/battery-full-alert

# Install systemd files
cp config/battery-full-alert.service ~/.config/systemd/user/
cp config/battery-full-alert.timer ~/.config/systemd/user/

# Install config file
cp config/battery-full-alert.conf ~/.config/

# Enable and start
systemctl --user daemon-reload
systemctl --user enable --now battery-full-alert.timer

echo "✅ Installation complete! The service will start automatically."
echo "🔋 Battery Full Alert is now monitoring your battery."
