#!/bin/bash

# Configuration
GITHUB_REPO="pwrlabs/PWR-Validator"
CONFIG_DIR="$HOME/pwr_validator"  # Default directory, can be adjusted as needed
VALIDATOR_PASSWORD="123456789"     # Your validator password
NODE_IP=$(curl -s ipinfo.io/ip)   # Auto-detect IP address

# Log file setup
LOG_FILE="${CONFIG_DIR}/auto_update.log"

# Create directory if it doesn't exist
mkdir -p "$CONFIG_DIR"
cd "$CONFIG_DIR" || { echo "Cannot change to $CONFIG_DIR"; exit 1; }

# Ensure log file exists
touch "$LOG_FILE"

# Function to append to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting PWR-Validator auto-update check..."

# Get the latest release version from GitHub
log "Checking for new releases..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

if [ -z "$LATEST_VERSION" ]; then
    log "Failed to fetch the latest version. Check your internet connection or GitHub API access."
    exit 1
fi

# Get current version (if any)
CURRENT_VERSION_FILE="${CONFIG_DIR}/.current_version"
if [ -f "$CURRENT_VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$CURRENT_VERSION_FILE")
else
    CURRENT_VERSION="none"
fi

log "Latest version: $LATEST_VERSION"
log "Current version: $CURRENT_VERSION"

# If versions are the same, exit
if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
    log "Already running the latest version. No update needed."
    exit 0
fi

log "New version detected. Updating from $CURRENT_VERSION to $LATEST_VERSION"

# Stop the running validator
log "Stopping current validator process..."
sudo pkill java
sudo pkill -9 java

# Remove old files
log "Removing old files..."
sudo rm -rf validator.jar config.json nohup.out rocksdb blocks merkleTree rpcdata

# If first V15 update, also delete wallet
if [[ "$CURRENT_VERSION" == "none" || "$CURRENT_VERSION" < "15.0.0" ]]; then
    log "First V15 update detected, removing wallet..."
    sudo rm -f wallet
fi

# Download new version
log "Downloading new version $LATEST_VERSION..."
wget -q "https://github.com/${GITHUB_REPO}/releases/download/${LATEST_VERSION}/validator.jar"
if [ $? -ne 0 ]; then
    log "Failed to download validator.jar"
    exit 1
fi

# Download new config
log "Downloading new config.json..."
wget -q "https://github.com/${GITHUB_REPO}/raw/refs/heads/main/config.json"
if [ $? -ne 0 ]; then
    log "Failed to download config.json"
    exit 1
fi

# Create password file
log "Creating password file..."
echo "$VALIDATOR_PASSWORD" > password

# Start the validator
log "Starting validator with version $LATEST_VERSION..."
nohup sudo java -jar validator.jar --ip "$NODE_IP" --password password > nohup.out 2>&1 &

# Save the current version for future checks
echo "$LATEST_VERSION" > "$CURRENT_VERSION_FILE"

log "Update completed successfully!"
log "You can check validator logs using: tail -n 1000 nohup.out -f"

# Exit with success
exit 0

# USAGE INSTRUCTIONS
# 
# 1. Save this script to a file (e.g., auto_update_pwr_validator.sh)
# 
# 2. Make it executable:
#    chmod +x auto_update_pwr_validator.sh
#
# 3. Run it manually to test:
#    ./auto_update_pwr_validator.sh
#
# 4. Set up hourly automatic updates by adding to crontab:
#    (a) Open crontab editor:
#        crontab -e
#    
#    (b) Add this line to check every hour:
#        0 * * * * /full/path/to/auto_update_pwr_validator.sh
#
# 5. To install automatically right now with hourly checks:
#    bash -c 'SCRIPT_PATH="$HOME/auto_update_pwr_validator.sh"; cat > "$SCRIPT_PATH" && chmod +x "$SCRIPT_PATH" && (crontab -l 2>/dev/null; echo "0 * * * * $SCRIPT_PATH") | crontab -'
