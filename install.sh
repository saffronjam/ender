#!/bin/bash
set -e

SERVICE_DIR="/etc/systemd/system"
REPO_DIR="$(realpath "$(dirname "$0")")"

echo "🛠️ Installing 3D printer viewer services..."

# Copy and enable docker-compose systemd service
sudo tee "$SERVICE_DIR/printer-viewer.service" > /dev/null <<EOF
[Unit]
Description=3D Printer Viewer - Docker Compose Service
After=network-online.target docker.service
Requires=docker.service

[Service]
WorkingDirectory=$REPO_DIR
ExecStart=/usr/bin/docker compose up --build --remove-orphans
ExecStop=/usr/bin/docker compose down
Restart=always
TimeoutStopSec=10
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Copy and enable capture timer
sudo tee "$SERVICE_DIR/capture-frame.service" > /dev/null <<EOF
[Unit]
Description=Capture a webcam frame for 3D printer snapshot

[Service]
Type=oneshot
ExecStart=$REPO_DIR/pi-capture.sh $REPO_DIR/frames
EOF

sudo tee "$SERVICE_DIR/capture-frame.timer" > /dev/null <<EOF
[Unit]
Description=Capture webcam frame every second

[Timer]
OnBootSec=10
OnUnitActiveSec=1s
AccuracySec=500ms
Unit=capture-frame.service

[Install]
WantedBy=timers.target
EOF

# Make sure the capture script is executable
chmod +x "$REPO_DIR/pi-capture.sh"

# Reload systemd and enable services
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable printer-viewer.service
sudo systemctl enable capture-frame.timer

# Start the services
sudo systemctl start printer-viewer.service
sudo systemctl start capture-frame.timer

echo "✅ Installation complete!"