# Bluetooth Setup Guide for Battery Widget

This guide will help you set up Bluetooth with battery monitoring support for the KDE Battery Widget.

## 1. Check Current System Status

```bash
# Check Bluetooth service status
systemctl status bluetooth.service

# Check if BluezQt QML module is installed
ls /usr/lib/qt6/qml/org/kde/bluezqt/qmldir
# or for Qt5
ls /usr/lib/qt5/qml/org/kde/bluezqt/qmldir
```

## 2. Required Installations

### Install Bluetooth Stack and Tools

```bash
sudo apt update
sudo apt install -y bluez bluez-tools
```

### Install BluezQt QML Module (Required for KDE Plasma)

```bash
sudo apt install -y qml-module-org-kde-bluezqt
```

## 3. Enable Bluetooth Service

```bash
# Enable Bluetooth to start on boot
sudo systemctl enable bluetooth.service

# Start Bluetooth service
sudo systemctl start bluetooth.service

# Verify it's running
systemctl status bluetooth.service
```

## 4. Enable Experimental Features (For Battery Reporting)

Some Bluetooth devices require experimental features to report battery levels.

### Method 1: Using systemctl edit (Recommended)

```bash
sudo systemctl edit bluetooth.service
```

Add these lines in the editor that opens:

```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/bluetoothd -E
```

Save and exit (Ctrl+O, Enter, Ctrl+X if using nano)

Then apply changes:

```bash
sudo systemctl daemon-reload
sudo systemctl restart bluetooth.service
```

### Method 2: Edit Configuration File

```bash
sudo nano /etc/bluetooth/main.conf
```

Find and uncomment/add this line:

```ini
Experimental = true
```

Save and restart:

```bash
sudo systemctl restart bluetooth.service
```

## 5. Pair Your Bluetooth Devices

### Using bluetoothctl (Command Line)

```bash
bluetoothctl
```

Inside bluetoothctl, run:

```
power on
agent on
default-agent
scan on
```

Wait for your device to appear, note the MAC address (e.g., `E3:8B:5B:51:CB:26`), then:

```
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
exit
```

### Using KDE Bluetooth GUI

1. Open **System Settings**
2. Go to **Bluetooth**
3. Click **Add New Device**
4. Select your device and follow pairing instructions

## 6. Verify Battery Support

### Check if Device Reports Battery

```bash
# List all paired Bluetooth devices
bluetoothctl devices

# Check battery info for specific device
bluetoothctl info XX:XX:XX:XX:XX:XX | grep -i battery
```

### Using D-Bus (More Detailed)

Replace `XX_XX_XX_XX_XX_XX` with your device's MAC address (replace colons with underscores):

```bash
dbus-send --print-reply=literal --system --dest=org.bluez \
  /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX \
  org.freedesktop.DBus.Properties.Get \
  string:"org.bluez.Battery1" string:"Percentage"
```

### Example with Real Device

For device `E3:8B:5B:51:CB:26`:

```bash
dbus-send --print-reply=literal --system --dest=org.bluez \
  /org/bluez/hci0/dev_E3_8B_5B_51_CB_26 \
  org.freedesktop.DBus.Properties.Get \
  string:"org.bluez.Battery1" string:"Percentage"
```

## 7. Reload the Battery Widget

After setting up Bluetooth:

1. Right-click the battery widget → **Remove**
2. Right-click desktop → **Add Widgets**
3. Find and add **Battery Widget**
4. Your Bluetooth devices should now appear with battery levels!

## 8. Troubleshooting

### Battery Not Showing?

1. **Make sure experimental features are enabled** (`-E` flag or `Experimental = true`)
2. **Reconnect the device** after enabling experimental features
3. **Some devices don't support battery reporting** - not all Bluetooth devices expose battery info
4. **Check Bluetooth version** - BLE 4.0+ is recommended for battery support

### Check Bluetooth Logs

```bash
sudo journalctl -u bluetooth.service -f
```

### Restart Bluetooth Completely

```bash
sudo systemctl stop bluetooth.service
sudo rfkill block bluetooth
sudo rfkill unblock bluetooth
sudo systemctl start bluetooth.service
```

### Check Connected Devices

```bash
bluetoothctl devices Connected
```

### Verify Widget Has BluezQt

```bash
# Check if the QML module is accessible
qmlscene --list-modules 2>&1 | grep -i bluez
```

## 9. Common Issues

### Issue: "bluetooth.service failed to start"

**Solution**: Check the bluetoothd path:

```bash
which bluetoothd
```

If it's at `/usr/libexec/bluetooth/bluetoothd` instead of `/usr/sbin/bluetoothd`, update the override config:

```bash
sudo systemctl edit bluetooth.service
```

Use the correct path in `ExecStart`.

### Issue: "Permission denied" when accessing battery

**Solution**: Make sure you're in the `bluetooth` group:

```bash
sudo usermod -aG bluetooth $USER
```

Log out and log back in for changes to take effect.

### Issue: Device connects but no battery info

**Possible reasons**:
- Device doesn't support battery reporting
- Experimental features not enabled
- Need to reconnect device after enabling experimental features

## 10. Testing

After setup, test your widget:

1. **Plug/unplug laptop charger** - Icon should adjust without overflow
2. **Let battery drain to < 20%** - Circle should turn red
3. **Connect Bluetooth devices** - Should see mouse, earbuds with battery levels
4. **Icons should be custom SVGs** from the `device-icons` folder
