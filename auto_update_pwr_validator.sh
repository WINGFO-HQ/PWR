#!/bin/bash

# Configuration
GITHUB_REPO="pwrlabs/PWR-Validator"
CONFIG_DIR="$HOME/pwr_validator"  # Default directory, can be adjusted as needed
VALIDATOR_PASSWORD="99025109"     # Your validator password
NODE_IP=$(curl -s ipinfo.io/ip)   # Auto-detect IP address

# Log file setup
LOG_FILE="${CONFIG_DIR}/auto_update.log"

# Create directory if it doesn't exist
mkdir -p "$CONFIG_DIR"
cd "$CONFIG_DIR" || { echo "Cannot change to $CONFIG_DIR"; exit 1; }

# Ensure log file exists
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(/bin/date)] Starting PWR-Validator auto-update check..."

# Get the latest release version from GitHub
echo "[$(/bin/date)] Checking for new releases..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

if [ -z "$LATEST_VERSION" ]; then
    echo "[$(/bin/date)] Failed to fetch the latest version. Check your internet connection or GitHub API access."
    exit 1
fi

# Get current version (if any)
CURRENT_VERSION_FILE="${CONFIG_DIR}/.current_version"
if [ -f "$CURRENT_VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$CURRENT_VERSION_FILE")
else
    CURRENT_VERSION="none"
fi

echo "[$(/bin/date)] Latest version: $LATEST_VERSION"
echo "[$(/bin/date)] Current version: $CURRENT_VERSION"

# If versions are the same, exit
if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
    echo "[$(/bin/date)] Already running the latest version. No update needed."
    exit 0
fi

echo "[$(/bin/date)] New version detected. Updating from $CURRENT_VERSION to $LATEST_VERSION"

# Stop the running validator
echo "[$(/bin/date)] Stopping current validator process..."
sudo pkill java
sudo pkill -9 java

# Remove old files
echo "[$(/bin/date)] Removing old files..."
sudo rm -rf validator.jar config.json nohup.out rocksdb blocks merkleTree rpcdata

# If first V15 update, also delete wallet
if [[ "$CURRENT_VERSION" == "none" || "$CURRENT_VERSION" < "15.0.0" ]]; then
    echo "[$(/bin/date)] First V15 update detected, removing wallet..."
    sudo rm -f wallet
fi

# Download new version
echo "[$(/bin/date)] Downloading new version $LATEST_VERSION..."
wget -q "https://github.com/${GITHUB_REPO}/releases/download/${LATEST_VERSION}/validator.jar"
if [ $? -ne 0 ]; then
    echo "[$(/bin/date)] Failed to download validator.jar"
    exit 1
fi

# Download new config
echo "[$(/bin/date)] Downloading new config.json..."
wget -q "https://github.com/${GITHUB_REPO}/raw/refs/heads/main/config.json"
if [ $? -ne 0 ]; then
    echo "[$(/bin/date)] Failed to download config.json"
    exit 1
fi

# Create password file
echo "[$(/bin/date)] Creating password file..."
echo "$VALIDATOR_PASSWORD" > password

# Start the validator
echo "[$(/bin/date)] Starting validator with version $LATEST_VERSION..."
nohup sudo java -jar validator.jar --ip "$NODE_IP" --password password > nohup.out 2>&1 &

# Save the current version for future checks
echo "$LATEST_VERSION" > "$CURRENT_VERSION_FILE"

echo "[$(/bin/date)] Update completed successfully!"
echo "[$(/bin/date)] You can check validator logs using: tail -n 1000 nohup.out -f"

# Exit with success
exit 0
