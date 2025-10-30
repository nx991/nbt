#!/bin/bash

# @fileOverview Uninstaller for NBT
# @author nx991 (adapted from MasterHide)
# @Copyright © 2025 nbt
# @license MIT

# Ask user for confirmation
echo "This script will uninstall NBT and all associated files. Are you sure you want to proceed? (y/n)"
read CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Uninstallation canceled."
    exit 0
fi

# -------- Auto-detect username (from installer) --------
USERNAME="${SUDO_USER:-$(whoami)}"
if [[ -z "$USERNAME" || "$USERNAME" == "root" ]]; then
  POSSIBLE_USER="$(logname 2>/dev/null || true)"
  if [[ -n "${POSSIBLE_USER:-}" && "${POSSIBLE_USER}" != "root" ]]; then
    USERNAME="$POSSIBLE_USER"
  fi
fi

HOME_DIR=$(eval echo "~$USERNAME")
if [[ ! -d "$HOME_DIR" ]]; then
    echo "Could not auto-detect user home directory. Aborting."
    exit 1
fi
echo "Auto-detected user: $USERNAME (Home: $HOME_DIR)"
# -------- End auto-detect --------


# Stop and disable the systemd service
echo "Stopping and disabling the NBT service..."
sudo systemctl stop nbt
sudo systemctl disable nbt

# Remove the systemd service file
echo "Removing the NBT systemd service file..."
sudo rm -f /etc/systemd/system/nbt.service

# Reload systemd to reflect changes
sudo systemctl daemon-reload

# Remove the NBT directory and its contents
echo "Removing the NBT directory..."
sudo rm -rf "$HOME_DIR/nbt"

# Remove SSL certificates
echo "Removing SSL certificates..."
sudo rm -rf /var/lib/nbt/certs

# Remove acme.sh
echo "Removing acme.sh (SSL certificate tool)..."
sudo rm -rf "$HOME_DIR/.acme.sh"
sudo rm -rf "/root/.acme.sh" # Also check root's home

# Remove cron job added by acme.sh
echo "Removing acme.sh cron job..."
(sudo crontab -u $USERNAME -l 2>/dev/null | grep -v "$HOME_DIR/.acme.sh/acme.sh --cron" | sudo crontab -u $USERNAME -) || true
(sudo crontab -u root -l 2>/dev/null | grep -v "/root/.acme.sh/acme.sh --cron" | sudo crontab -u root -) || true

# Remove log files
echo "Removing NBT log files..."
sudo rm -f /var/log/nbt.log

# Optional: Remove Python dependencies
echo "Do you want to uninstall Python dependencies installed for NBT? (y/n)"
read REMOVE_DEPS

if [ "$REMOVE_DEPS" == "y" ]; then
    echo "Uninstalling Python dependencies..."
    # Match dependencies from the installer
    sudo apt remove -y python3-pip python3-venv git sqlite3 socat unzip curl
    sudo apt autoremove -y
else
    echo "Skipping Python dependency removal."
fi

# Final message
echo "NBT has been successfully uninstalled."