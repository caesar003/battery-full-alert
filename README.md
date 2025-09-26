# Battery Full Alert

> Smart battery notification system for Linux with GNOME/systemd

Monitors your laptop battery and sends desktop notifications when it reaches a configurable threshold (default 95%). Prevents notification spam by tracking charging sessions and only alerting once per charge cycle.

## Features

- 🔋 Configurable battery threshold (default: 95%)
- 🔊 Optional sound notifications
- 🚫 Smart notification deduplication
- ⚙️ Systemd timer integration
- 📦 Debian package support
- 🎛️ User-configurable settings

## Installation

### Option 1: Debian Package (Recommended)

```bash
# Build and install
make deb
sudo dpkg -i battery-full-alert_1.0.0_all.deb

# Enable for current user
systemctl --user enable --now battery-full-alert.timer
```

### Option 2: Script Installation

```bash
./install.sh
```

### Dependencies

- `upower` - Battery information
- `libnotify-bin` - Desktop notifications
- `pulseaudio-utils` - Sound playback

```bash
# Ubuntu/Debian
sudo apt install upower libnotify-bin pulseaudio-utils

# Fedora
sudo dnf install upower libnotify pulseaudio-utils
```

## Configuration

Copy the system config to your user directory to customize:

```bash
cp /etc/battery-full-alert/battery-full-alert.conf ~/.config/
```

Edit `~/.config/battery-full-alert.conf`:

```bash
THRESHOLD=95                    # Battery percentage threshold
SOUND_FILE=/usr/share/sounds/freedesktop/stereo/complete.oga
ENABLE_SOUND=true              # Enable/disable sound
```

## Usage

The service runs automatically via systemd timer every 5 minutes.

### Manual Control

```bash
# Check status
systemctl --user status battery-full-alert.timer

# Stop/start
systemctl --user stop battery-full-alert.timer
systemctl --user start battery-full-alert.timer

# View logs
journalctl --user -u battery-full-alert.service
```

### Test Manually

```bash
battery-full-alert
```

## Uninstallation

### Debian Package

```bash
sudo dpkg -r battery-full-alert
```

### Script Installation

```bash
./uninstall.sh
```

## Development

```bash
# Test dependencies
make test

# Build debian package
make deb

# Clean build files
make clean
```

## Troubleshooting

**No notifications appearing?**

- Check if notification daemon is running: `pgrep notification`
- Test notifications: `notify-send "Test" "Hello World"`

**Sound not playing?**

- Verify sound file exists: `ls -la /usr/share/sounds/freedesktop/stereo/complete.oga`
- Test audio: `paplay /usr/share/sounds/freedesktop/stereo/complete.oga`

**Timer not running?**

- Check timer status: `systemctl --user status battery-full-alert.timer`
- Check logs: `journalctl --user -u battery-full-alert.timer`

## License

MIT License - See LICENSE file for details.
