#!/bin/bash

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

set -o errexit
set -o nounset
set -o pipefail

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

readonly tftp_dir="/var/lib/tftpboot"
readonly tftp_config_file="/etc/default/tftpd-hpa"
readonly tftp_service="tftpd-hpa"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

log() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
    exit 1
}

backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        sudo cp "$file" "${file}.bak-$(date +%Y%m%d%H%M%S)"
        log "Backed up ${file}"
    fi
}

#------------------------------------------------------------------------------
# Main script
#------------------------------------------------------------------------------

log "Starting TFTP server setup on ${HOSTNAME}"

sudo setenforce 1

log "Updating package list and installing dependencies"
sudo apt-get update
sudo apt-get install -y tftpd-hpa tftp || error "Failed to install TFTP packages"

log "Creating TFTP directory and setting permissions"
sudo mkdir -p "${tftp_dir}" || error "Failed to create TFTP directory"
sudo chown -R tftp:tftp "${tftp_dir}" || error "Failed to set owner for TFTP directory"
sudo chmod -R 777 "${tftp_dir}" || error "Failed to set permissions for TFTP directory"

log "Backing up and configuring TFTP server"
backup_file "${tftp_config_file}"
sudo tee "${tftp_config_file}" > /dev/null <<EOF
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="${tftp_dir}"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure --create"
EOF

log "Restarting and enabling TFTP service"
sudo systemctl restart "${tftp_service}" || error "Failed to restart TFTP service"
sudo systemctl enable "${tftp_service}" || error "Failed to enable TFTP service"

log "TFTP service status:"
systemctl status "${tftp_service}" --no-pager || error "Failed to get service status"

log "TFTP server setup completed successfully"