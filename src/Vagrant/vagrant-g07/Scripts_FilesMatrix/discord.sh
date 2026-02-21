#! /bin/bash
#
# Provisioning script for Synapse Matrix

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
# set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export PROVISIONING_FILES="/vagrant/Scripts_FilesMatrix"

#------------------------------------------------------------------------------
# Code
#------------------------------------------------------------------------------

# documentatie: https://github.com/mautrix/discord, https://docs.mau.fi/bridges/go/setup.html?bridge=discord

# Step 1: Installing Dependencies
echo "Installing Dependencies"
sudo yum install cmake gcc-c++ make -y

# Step 2: Build olm library
echo "Building olm library"
cd /usr/local/lib/
sudo rm -rf olm 
git clone https://gitlab.matrix.org/matrix-org/olm.git
cd olm
sudo mkdir build && cd build
sudo cmake ..
sudo make
sudo make install
echo "Succesfully built olm library"

# Step 3: Setting up environment variables
echo "Setting up environment variables..."
export MAUTRIX_LIB_PATH=/usr/local/lib:$MAUTRIX_LIB_PATH
echo 'export MAUTRIX_LIB_PATH=/usr/local/lib:$MAUTRIX_LIB_PATH' >> ~/.bashrc
source ~/.bashrc

# Step 4: Installation of bridge
echo "Installing mautrix discord bridge"
cd /opt/
git clone https://github.com/mautrix/discord.git mautrix-discord
echo "Executed clone mautrix"
cd mautrix-discord
sudo dnf install golang -y
./build.sh
echo "Executed build mautrix"

# Step 5: Create and configure the bridge
sqlite3 database.db <<EOF
CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, password TEXT);
INSERT INTO users (username, password) VALUES ('bridge', 'bridge');
.quit
EOF

# Step 6: Configuration Mautrix
echo "Configuring Mautrix-discord"
cp example-config.yaml config.yaml
sed -i 's#https://matrix.example.com#http://matrix.i3-syndus.internal#g' config.yaml
sed -i 's#domain: example.com#domain: matrix.i3-syndus.internal#g' config.yaml
sed -i 's#http://localhost:29334#http://matrix.i3-syndus.internal:29334#g' config.yaml
sed -i 's#type: postgres#type: sqlite3-fk-wal#g' config.yaml
sed -i 's#uri: postgres://user:password@host/database?sslmode=disable#uri: file:/opt/mautrix-discord/database.db?_txlock=immediate#g' config.yaml

# bridge.permissions not configured error oplossing:
sed -i 's#example.com: https://example.com#example.com: http://matrix.i3-syndus.internal#g' config.yaml
sed -i 's#"example.com": user#"matrix.i3-syndus.internal": user#g' config.yaml
sed -i 's#"@admin:example.com": admin#"@bot:matrix.i3-syndus.internal": user#g' config.yaml

# Step 7: Generate and register appservice
echo "Generating and registering appservice..."
echo "/usr/local/lib/olm/build" | sudo tee -a /etc/ld.so.conf
echo "/usr/local/lib64" | sudo tee -a /etc/ld.so.conf
sudo ldconfig
./mautrix-discord -g

# Step 8: Creating the service for Mautrix on startup
echo "Creating the Mautrix discord.service"
sudo cp "${PROVISIONING_FILES}/discord.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable discord.service
sudo systemctl start discord.service

if ! grep -q "app_service_config_files:" /home/vagrant/synapse/homeserver.yaml; then
  echo -e "\napp_service_config_files:\n- /opt/mautrix-discord/registration.yaml" >> /home/vagrant/synapse/homeserver.yaml
fi

sudo systemctl restart synapse.service

# ------------------------------------------------------------------------------------------------------------------------------------------------------- #

echo "Mautrix Discord Bridge service complete!"