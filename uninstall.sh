#!/bin/bash
set -e

echo "Uninstalling Battery Full Alert..."

# Stop and disable timer
systemctl --user disable --now battery-full-alert.timer 2>/dev/null || true

# Remove files
rm -f ~/.local/bin/battery-full-alert
rm -f ~/.config/systemd/user/battery-full-alert.service
rm -f ~/.config/systemd/user/battery-full-alert.timer
rm -f ~/.config/battery-full-alert.conf
rm -f ~/.cache/battery-full-notified

# Reload systemd
systemctl --user daemon-reload

echo "✅ Uninstallation complete!"
