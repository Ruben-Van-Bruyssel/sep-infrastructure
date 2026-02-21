#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if command -v getenforce &>/dev/null; then
    SELINUX_STATUS=$(getenforce)
    if [ "$SELINUX_STATUS" != "Enforcing" ]; then
        sudo setenforce 1
        exit 0
    fi
else
    echo "SELinux lijkt niet geïnstalleerd te zijn op dit systeem."
    exit 1
fi

echo "SELinux draait in Enforcing modus. Toepassen van configuratie-aanpassingen..."

# 1. Zorg dat HTTP daemons (zoals Nginx) uitgaande verbindingen mogen maken
echo "Inschakelen: SELinux boolean httpd_can_network_connect..."
sudo setsebool -P httpd_can_network_connect 1

# 2. Zorg ervoor dat poorten 80 en 443 correct gelabeld zijn als http_port_t
echo "Controleren en labelen van poort 80 als http_port_t..."
if sudo semanage port -a -t http_port_t -p tcp 80 2>/dev/null; then
    echo "Poort 80 succesvol gelabeld."
else
    echo "Poort 80 is reeds gelabeld."
fi

echo "Controleren en labelen van poort 443 als http_port_t..."
if sudo semanage port -a -t http_port_t -p tcp 443 2>/dev/null; then
    echo "Poort 443 succesvol gelabeld."
else
    echo "Poort 443 is reeds gelabeld."
fi

echo "Updating system packages..."
sudo dnf update -y

echo "Installing dependencies..."
sudo dnf install -y \
    dnf-plugins-core \
    curl \
    git \
    unzip \
    firewalld


echo "Installing jellyfin..."
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Enabling and starting e..."
sudo systemctl enable --now docker

# Create media folders
echo "Creating media folder structure..."
sudo mkdir -p /media/jellyfin/{Videos,Photos}
sudo chown -R 1000:1000 /media/jellyfin

# Optional: copy media from /vagrant if present
[ -d "/vagrant/media/video" ] && sudo cp -r /vagrant/media/video/* /media/jellyfin/Videos/ || echo "No videos found in shared folder"
[ -d "/vagrant/media/foto" ] && sudo cp -r /vagrant/media/foto/* /media/jellyfin/Photos/ || echo "No photos found in shared folder"
# Remove existing jellyfin container if it exists
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^jellyfin$"; then
  echo "Removing existing jellyfin container..."
  sudo docker rm -f jellyfin
fi

# Run Jellyfin in 
echo "Running Jellyfin..."
sudo docker run -d \
  --name jellyfin \
  --restart unless-stopped \
  -p 8096:8096 \
  -v /media/jellyfin/Videos:/media/video \
  -v /media/jellyfin/Photos:/media/foto \
  -v jellyfin_config:/config \
  -v jellyfin_cache:/cache \
  jellyfin/jellyfin

# Enable and start firewalld if necessary
echo "Configuring firewall..."
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-port=8096/tcp
sudo firewall-cmd --reload

# Final output
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Jellyfin is now running"
echo "Access it at: http://${IP_ADDRESS}:8096"
