#!/bin/bash
# Full provisioning script for Synapse Matrix
set -o errexit
set -o nounset
set -o pipefail

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
SERVER_NAME="matrix.i3-syndus.internal"
SYNAPSE_DIR="/home/vagrant/synapse"
NGINX_CONF_DIR="/etc/nginx/conf.d/"
SYSTEMD_DIR="/etc/systemd/system/"
CERT_PATH="/etc/ssl/certs/myCertificate.crt"
KEY_PATH="/etc/ssl/certs/myKey.key"

SERVICE_SYNAPSE="synapse.service"
SERVICE_SHUTDOWN="matrix_message_on_shutdown.service"

SYNAPSE_SERVICE_SRC="/vagrant/Scripts_FilesMatrix/synapse.service"
SHUTDOWN_SERVICE_SRC="/vagrant/Scripts_FilesMatrix/matrix_message_on_shutdown.service"
USERS_SCRIPT="/vagrant/Scripts_FilesMatrix/users.sh"
ROOM_SCRIPT="/vagrant/Scripts_FilesMatrix/room.sh"
SEND_MSG_SCRIPT="/vagrant/Scripts_FilesMatrix/send_matrix_message.sh"
NGINX_CONF_SRC="/vagrant/Scripts_FilesMatrix/nginx.conf"
DISCORD_SCRIPT="/vagrant/Scripts_FilesMatrix/discord.sh"
HOMESERVER_YAML="$SYNAPSE_DIR/homeserver.yaml"

log() { echo "[INFO] $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

#------------------------------------------------------------------------------
# Initial setup
#------------------------------------------------------------------------------
sudo setenforce 0 || true
sudo systemctl restart NetworkManager || true

#------------------------------------------------------------------------------
# Step 1: Install dependencies
#------------------------------------------------------------------------------
log "Installing dependencies..."
sudo dnf update -y
sudo dnf install -y epel-release jq python3 python3-pip git nginx firewalld sqlite
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

#------------------------------------------------------------------------------
# Step 2: Python virtualenv for Synapse
#------------------------------------------------------------------------------
log "Setting up Python virtualenv..."
python3 -m venv "$SYNAPSE_DIR"
source "$SYNAPSE_DIR/bin/activate"
pip install --upgrade pip
pip install matrix-synapse

#------------------------------------------------------------------------------
# Step 3: Generate Synapse configuration
#------------------------------------------------------------------------------
log "Generating Synapse configuration..."
cd "$SYNAPSE_DIR"
python -m synapse.app.homeserver \
    --server-name "$SERVER_NAME" \
    --config-path "$HOMESERVER_YAML" \
    --generate-config \
    --report-stats=no

sed -i 's/#enable_registration: false/enable_registration: true/' "$HOMESERVER_YAML"

#------------------------------------------------------------------------------
# Step 4: Permissions
#------------------------------------------------------------------------------
log "Setting permissions..."
sudo mkdir -p /etc/synapse
sudo cp "$HOMESERVER_YAML" /etc/synapse/
sudo chown -R vagrant:vagrant "$SYNAPSE_DIR" /etc/synapse

#------------------------------------------------------------------------------
# Step 5: Firewall
#------------------------------------------------------------------------------
log "Configuring firewall..."
sudo systemctl start firewalld
sudo firewall-cmd --add-service={ssh,http,https} --permanent
sudo firewall-cmd --add-port=8008/tcp --permanent
sudo firewall-cmd --add-port=8448/tcp --permanent
sudo firewall-cmd --add-port=29334/tcp --permanent
sudo firewall-cmd --reload

#------------------------------------------------------------------------------
# Step 6: Nginx
#------------------------------------------------------------------------------
log "Configuring Nginx..."
if [ -f "$NGINX_CONF_SRC" ]; then
    sudo cp "$NGINX_CONF_SRC" "$NGINX_CONF_DIR"
    sudo systemctl enable nginx
    sudo systemctl restart nginx
else
    error "nginx.conf not found at $NGINX_CONF_SRC"
fi

#------------------------------------------------------------------------------
# Step 7: SSL
#------------------------------------------------------------------------------
log "Creating SSL certificates..."
sudo mkdir -p /etc/ssl/certs
sudo chmod 700 /etc/ssl/certs
sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -keyout "$KEY_PATH" -out "$CERT_PATH" \
    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=$SERVER_NAME"
sudo chmod 600 "$KEY_PATH" "$CERT_PATH"

echo "127.0.0.1 $SERVER_NAME" | sudo tee -a /etc/hosts
echo "192.168.151.63 www.$SERVER_NAME" | sudo tee -a /etc/hosts

#------------------------------------------------------------------------------
# Step 8: Synapse systemd service
#------------------------------------------------------------------------------
log "Setting up Synapse service..."
if [ -f "$SYNAPSE_SERVICE_SRC" ]; then
    sudo cp "$SYNAPSE_SERVICE_SRC" "$SYSTEMD_DIR"
    sudo systemctl unmask "$SERVICE_SYNAPSE" || true
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_SYNAPSE"
    sudo systemctl start "$SERVICE_SYNAPSE"
else
    error "synapse.service not found at $SYNAPSE_SERVICE_SRC"
fi

log "Waiting for Synapse to initialize..."
until curl -s http://localhost:8008/_matrix/client/versions >/dev/null 2>&1; do
    echo "Synapse not ready yet..."
    sleep 2
done
log "Synapse is up!"

#------------------------------------------------------------------------------
# Step 9: Users
#------------------------------------------------------------------------------
[ -f "$USERS_SCRIPT" ] && bash "$USERS_SCRIPT"

#------------------------------------------------------------------------------
# Step 10: Rooms
#------------------------------------------------------------------------------
[ -f "$ROOM_SCRIPT" ] && bash "$ROOM_SCRIPT"

#------------------------------------------------------------------------------
# Step 11: Shutdown message service
#------------------------------------------------------------------------------
if [ -f "$SEND_MSG_SCRIPT" ]; then
    sudo cp "$SEND_MSG_SCRIPT" /usr/local/bin/
    sudo chmod +x "/usr/local/bin/$(basename "$SEND_MSG_SCRIPT")"
else
    log "Warning: $SEND_MSG_SCRIPT not found, skipping send_matrix_message.sh"
fi

if [ -f "$SHUTDOWN_SERVICE_SRC" ]; then
    sudo cp "$SHUTDOWN_SERVICE_SRC" "$SYSTEMD_DIR"
    sudo systemctl unmask "$SERVICE_SHUTDOWN" || true
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_SHUTDOWN" || log "$SERVICE_SHUTDOWN already enabled"
    sudo systemctl start "$SERVICE_SHUTDOWN" || log "$SERVICE_SHUTDOWN already running"
else
    log "Warning: $SHUTDOWN_SERVICE_SRC not found, skipping $SERVICE_SHUTDOWN"
fi

#------------------------------------------------------------------------------
# Step 12: Discord bridge
#------------------------------------------------------------------------------
[ -f "$DISCORD_SCRIPT" ] && bash "$DISCORD_SCRIPT"

#------------------------------------------------------------------------------
# Step 13: Finish
#------------------------------------------------------------------------------
sudo setenforce 0 || true
log "Matrix server setup complete!"
