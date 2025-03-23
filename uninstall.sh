#!/bin/bash
set -e

SERVICE_DIR="/etc/systemd/system"

echo "🧹 Uninstalling 3D printer viewer services..."

# Stop and disable systemd units
sudo systemctl stop printer-viewer.service || true
sudo systemctl disable printer-viewer.service || true
sudo systemctl stop capture-frame.timer || true
sudo systemctl disable capture-frame.timer || true

# Remove unit files
sudo rm -f \
  "$SERVICE_DIR/ender-web.service" \
  "$SERVICE_DIR/ender-capture.service" \
  "$SERVICE_DIR/ender-capture.timer"

# Reload systemd
sudo systemctl daemon-reload

echo "✅ Uninstallation complete!"