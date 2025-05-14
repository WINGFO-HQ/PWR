# PWR
This repository contains an auto-update script for PWR Validator nodes. The script automatically checks for new releases of the PWR-Validator on GitHub and updates your validator when a new version is available.
# Disclaimer
This is an unofficial community tool. Use at your own risk.

## Features
- 🔄 Automatic hourly checks for new releases
- 🖥️ Automatic IP detection using curl -s ipinfo.io/ip
- 🚀 One-step installation
- 📝 Detailed logging for tracking update activities
- 🛡️ Safe updates with proper cleanup of old files
- ⚙️ Special handling for version-specific updates (e.g., V15 wallet handling)

## Quick Installation
Set up the entire system with just one command:
```bash
curl -s https://raw.githubusercontent.com/WINGFO-HQ/PWR/main/auto_update_pwr_validator.sh > $HOME/auto_update_pwr_validator.sh && chmod +x $HOME/auto_update_pwr_validator.sh && (crontab -l 2>/dev/null; echo "0 * * * * $HOME/auto_update_pwr_validator.sh") | crontab -
```

# This command will:
- Download the script to your home directory
- Make it executable
- Add it to your crontab to run every hour (at minute 0)

# Manual Installation
If you prefer to install manually:
- Clone this repository:
```bash 
git clone https://github.com/WINGFO-HQ/PWR.git && cd PWR
```

- Make the script executable:
```bash
chmod +x auto_update_pwr_validator.sh
```

- Test it manually:
```bash 
./auto_update_pwr_validator.sh
```

- Set up hourly automatic updates:
```bash 
crontab -e
```
Add the line:
```0 * * * * /full/path/to/auto_update_pwr_validator.sh```

# Configuration
The script has default settings that you can customize by editing the script:
```bash
# Configuration
GITHUB_REPO="pwrlabs/PWR-Validator"
CONFIG_DIR="$HOME/pwr_validator"   #Directory for validator files
VALIDATOR_PASSWORD="your_password" #Your validator password
NODE_IP=$(curl -s ipinfo.io/ip)    #Auto-detects your IP address
```

# Monitoring
- You can check the update logs at any time:
```bash
cat ~/pwr_validator/auto_update.log
```
- And monitor your validator:
```bash
bashtail -n 1000 ~/pwr_validator/nohup.out -f
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
