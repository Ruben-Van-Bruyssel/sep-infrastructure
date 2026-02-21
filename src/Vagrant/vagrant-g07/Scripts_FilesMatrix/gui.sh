#!/bin/bash
# 

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

sudo dnf update -y
sudo dnf groupinstall "Server with GUI" -y
sudo systemctl set-default graphical.target

echo "reebooting in a minute"
sleep 60

sudo reboot