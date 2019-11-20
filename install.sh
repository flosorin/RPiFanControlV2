#!/bin/bash

# Add execution rigths to the script
chmod +x src/FanControl.sh

# Copy script and service file in the rigth location
sudo cp src/fancontrol.service /etc/systemd/system/
sudo cp src/FanControl.sh /usr/local/bin/FanControl

# Add user to group gpio (create it if it does not exist)
if [ ! $(getent group gpio) ]; then
       sudo groupadd gpio	
fi
sudo usermod -aG gpio $(logname)

# Enable service to run at boot
sudo systemctl enable fancontrol


