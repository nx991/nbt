#!/bin/bash

# @fileOverview Check usage stats of X-SL
# @author MasterHide
# @Copyright © 2025 x404 MASTER™
# @license MIT
#
# You may not reproduce or distribute this work, in whole or in part, 
# without the express written consent of the copyright owner.
#
# For more information, visit: https://t.me/Dark_Evi


# Ask user for confirmation
echo "This script will uninstall Traffic-X and all associated files. Are you sure you want to proceed? (y/n)"
read CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Uninstallation canceled."
    exit 0
fi

# Stop and disable the systemd service
echo "Stopping and disabling the Traffic-X service..."
sudo systemctl stop traffic-x
sudo systemctl disable traffic-x

# Remove the systemd service file
echo "Removing the Traffic-X systemd service file..."
sudo rm -f /etc/systemd/system/traffic-x.service

# Reload systemd to reflect changes
sudo systemctl daemon-reload

# Ask for the OS username used during installation
echo "Enter the OS username used during installation (e.g., ubuntu):"
read USERNAME

# Remove the Traffic-X directory and its contents
echo "Removing the Traffic-X directory..."
sudo rm -rf /home/$USERNAME/Traffic-X

# Remove SSL certificates
echo "Removing SSL certificates..."
sudo rm -rf /var/lib/Traffic-X/certs

# Remove acme.sh (optional, if it was installed specifically for Traffic-X)
echo "Removing acme.sh (SSL certificate tool)..."
sudo rm -rf /root/.acme.sh

# Remove cron job added by acme.sh (if any)
echo "Removing acme.sh cron job..."
sudo crontab -l | grep -v "/root/.acme.sh/acme.sh --cron" | sudo crontab -

# Remove log files
echo "Removing Traffic-X log files..."
sudo rm -f /var/log/traffic-x.log

# Optional: Remove Python dependencies (if no longer needed)
echo "Do you want to uninstall Python dependencies installed for Traffic-X? (y/n)"
read REMOVE_DEPS

if [ "$REMOVE_DEPS" == "y" ]; then
    echo "Uninstalling Python dependencies..."
    sudo apt remove -y python3-pip python3-venv git sqlite3 socat
    sudo apt autoremove -y
else
    echo "Skipping Python dependency removal."
fi

# Final message
echo "Traffic-X has been successfully uninstalled."
