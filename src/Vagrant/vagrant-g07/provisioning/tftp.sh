#!/bin/bash

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit
set -o nounset
set -o pipefail

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# TFTP directory
readonly TFTP_DIR="/var/lib/tftpboot"

# Shared folder containing switch and router config files
readonly SHARED_FOLDER="/vagrant/Cisco"

# TFTP service and socket files
readonly TFTP_SERVICE_FILE="/etc/systemd/system/tftp.service"
readonly TFTP_SOCKET_FILE="/etc/systemd/system/tftp.socket"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

sudo setenforce 1

log "Starting TFTP server setup on ${HOSTNAME}"

log "Installing TFTP server and client packages"
dnf install -y tftp-server tftp || error "Failed to install TFTP packages"

log "Configuring TFTP server"

# Copy systemd service and socket files
cp /usr/lib/systemd/system/tftp.service "${TFTP_SERVICE_FILE}" || error "Failed to copy tftp.service"
cp /usr/lib/systemd/system/tftp.socket "${TFTP_SOCKET_FILE}" || error "Failed to copy tftp.socket"

log "Configuring TFTP service file"
cat <<EOF > "${TFTP_SERVICE_FILE}"
[Unit]
Description=Tftp Server
Requires=tftp.socket
Documentation=man:in.tftpd

[Service]
ExecStart=/usr/sbin/in.tftpd -c -p -s ${TFTP_DIR}
StandardInput=socket

[Install]
WantedBy=multi-user.target
Also=tftp.socket
EOF

log "Creating TFTP directory and setting permissions"
mkdir -p "${TFTP_DIR}" || error "Failed to create TFTP directory"
chmod 777 "${TFTP_DIR}" || error "Failed to set permissions for TFTP directory"

# Fix SELinux issues so it is enforcing and allowing TFTP
if command -v getenforce &>/dev/null && [[ "$(getenforce)" != "Disabled" ]]; then
    log "Applying SELinux permissions for TFTP"
    setsebool -P tftp_home_dir 1
    restorecon -R "${TFTP_DIR}"
fi

log "Copying switch and router config files from shared folder"
if [[ -d "${SHARED_FOLDER}" ]]; then
    cp "${SHARED_FOLDER}"/*.txt "${TFTP_DIR}/" || error "Failed to copy config files"
    log "Config files copied successfully"
else
    error "Shared folder ${SHARED_FOLDER} does not exist"
fi

log "Reloading systemd and starting TFTP service"
systemctl daemon-reload
systemctl enable --now tftp.socket tftp.service || error "Failed to enable and start TFTP service"
systemctl enable tftp.service

sudo systemctl stop firewalld

log "Verifying TFTP service status"
sudo systemctl start tftp
systemctl status tftp.socket || error "TFTP service is not running"

log "TFTP server setup completed successfully"