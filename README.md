# PWR
This repository contains an advanced auto-update script for PWR Validator nodes. The script checks for new releases of the PWR-Validator on GitHub and updates your validator when a new version is available.
# Features
- 🕰️ Watch mode - Continuously monitor for updates and wait until a new version is available
- 🌐 Automatic IP detection - Detects your server's IP address automatically
- 📈 Configurable check intervals - Set custom time intervals for update checks
- 📝 Detailed logging - Complete log of all activities with timestamps
- 🔄 Skip if latest version - Only updates when a new version is actually available
- 🔒 Preconfigured password - Uses a fixed password for validation

# Installation
- Download the script:

```bash
curl -s https://raw.githubusercontent.com/WINGFO-HQ/PWR/main/auto_update_pwr_validator.sh && chmod +x $HOME/auto_update_pwr_validator.sh
```

# Usage Options
Basic Usage
- Run the script once to check for and apply updates:
```bash
./auto_update_pwr_validator.sh
```

# Watch Mode
Run the script in watch mode to continuously check for updates until a new version is available:
```bash
./auto_update_pwr_validator.sh --watch
```
```This is useful when you want to ensure your validator gets updated as soon as a new version is released.```

# Custom Check Interval
- Set a custom interval (in seconds) for checking updates in watch mode:
```bash
./auto_update_pwr_validator.sh --watch --interval 300
```
The example above will check every 5 minutes.

# Automated Hourly Checks
Set up hourly automatic update checks via crontab:
```bash
crontab -e
```
- Add this line to check every hour: ```0 * * * * $HOME/auto_update_pwr_validator.sh```


# Set up everything with just one command:
One-Command Installation with Hourly Checks
```bash
curl -s https://raw.githubusercontent.com/WINGFO-HQ/PWR/main/auto_update_pwr_validator.sh > $HOME/auto_update_pwr_validator.sh && chmod +x $HOME/auto_update_pwr_validator.sh && (crontab -l 2>/dev/null; echo "0 * * * * $HOME/auto_update_pwr_validator.sh") | crontab -
```

# Configuration
To adjust the script configuration, edit these variables at the top of the script:
```bash
# Configuration
GITHUB_REPO="pwrlabs/PWR-Validator"
CONFIG_DIR="$HOME/pwr_validator"  # Directory for validator files
VALIDATOR_PASSWORD="123456789"    # Validator password
NODE_IP=$(curl -s ipinfo.io/ip)   # Auto-detects your IP address
```
- You can change the password by modifying the VALIDATOR_PASSWORD variable.

# Monitoring
- Monitor update logs:
```bash
cat ~/pwr_validator/auto_update.log
```
- Check validator status:
```bash
tail -n 1000 ~/pwr_validator/nohup.out -f
```

# Manual Update Process
If you prefer to update manually, you can follow these steps:
- Stop the old validator:
```bash
sudo pkill java && \
sudo pkill -9 java
```

- Remove old files:
```bash
sudo rm -rf validator.jar config.json nohup.out rocksdb blocks merkleTree rpcdata
```

- For first V15 update, also delete the wallet:
```bash
sudo rm wallet
```

- Download new version:
```bash
latest=$(curl -s https://api.github.com/repos/pwrlabs/PWR-Validator/releases/latest | grep tag_name | cut -d '"' -f 4) && \
wget https://github.com/pwrlabs/PWR-Validator/releases/download/$latest/validator.jar && \
wget https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json
```

- Create password file:

```bash
echo "123456789" > password
```

- Run the validator:
```bash
nohup sudo java -jar validator.jar --ip $(curl -s ipinfo.io/ip) --password password &
```

- Check logs:
```bash
tail -n 1000 nohup.out -f
```

# Disclaimer
This is an unofficial community tool. Use at your own risk.
# Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
