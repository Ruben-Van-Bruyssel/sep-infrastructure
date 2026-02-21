#!/bin/bash
#
# Provisioning script for installing Nextcloud on AlmaLinux
# Based on: https://orcacore.com/install-configure-nextcloud-almalinux-9/
# Enhancements:
#  - Skip installation if Nextcloud is already installed.
#  - Set SELinux to permissive (if enabled).
#  - Set Apache ServerName to a specific IP.
#  - Configure trusted domains to include 192.168.207.55.
#  - Ensure Nextcloud Calendar and Forms apps are installed.
#  - Configure Apache to serve Nextcloud as the root site.
#
#------------------------------------------------------------------------------

set -o errexit   # Abort if any command exits with a nonzero exit status.
set -o nounset   # Abort if an unbound variable is used.
set -o pipefail  # Do not mask errors within pipelines.

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

readonly PROVISIONING_SCRIPTS="/vagrant/provisioning"
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME:-default}"
readonly db_host="192.168.207.52"

readonly NEXTCLOUD_VERSION="latest"
readonly NEXTCLOUD_DIR="/var/www/html/nextcloud"
readonly NEXTCLOUD_DB_NAME="nextclouddb"
readonly NEXTCLOUD_DB_USER="nextcloud-user"
readonly NEXTCLOUD_DB_PASSWORD="password"

readonly NEXTCLOUD_ADMIN_USER="admin"
readonly NEXTCLOUD_ADMIN_PASS="admin"

readonly MY_IP="192.168.207.55"

readonly VHOST_CONF="/etc/httpd/conf.d/nextcloud.conf"

#------------------------------------------------------------------------------
# Global Provisioning Tasks
#------------------------------------------------------------------------------

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

# Optional: Disable SELinux (or set to permissive) if enabled.
if [ -f /etc/selinux/config ]; then
    echo "Setting SELinux to permissive..."
    sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
    sudo setenforce 0 || true
fi

# Ensure the directory exists before creating the ServerName file
sudo mkdir -p /etc/httpd/conf.d/

# Set Apache ServerName to MY_IP to ensure Apache listens on that interface.
echo "Setting Apache ServerName to ${MY_IP}..."
echo "ServerName ${MY_IP}" | sudo tee /etc/httpd/conf.d/servername.conf

# Allow some time for network initialization.
sleep 5

# Update system and install the EPEL and Remi repositories.
sudo dnf update -y
sudo dnf install -y epel-release
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

# Reset and enable PHP 8.1 from the Remi repository.
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.1 -y

# Install PHP, required extensions, Apache, and MariaDB.
sudo dnf install -y php php-curl php-bcmath php-gd php-soap php-zip \
  php-mbstring php-mysqlnd php-xml php-intl php-cli php-devel php-pear \
  php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-ldap unzip \
  httpd mariadb-server mariadb

# Start and enable necessary services.
sudo systemctl enable --now httpd
sudo systemctl enable --now firewalld
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
sudo systemctl enable --now mariadb

# Verify PHP version.
php -v

# Increase PHP memory limit.
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php.ini

#------------------------------------------------------------------------------
# Nextcloud Installation Section (Will be skipped if already installed)
#------------------------------------------------------------------------------

if [ -f "${NEXTCLOUD_DIR}/config/config.php" ]; then
    echo "Nextcloud is already installed. Skipping installation steps."
else
    # Set up Nextcloud database.
    echo "Configuring Nextcloud database..."
    sudo mysql -u root <<EOF
DROP USER IF EXISTS '${NEXTCLOUD_DB_USER}'@'localhost';
CREATE USER '${NEXTCLOUD_DB_USER}'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASSWORD}';
DROP DATABASE IF EXISTS ${NEXTCLOUD_DB_NAME};
CREATE DATABASE ${NEXTCLOUD_DB_NAME};
GRANT ALL PRIVILEGES ON ${NEXTCLOUD_DB_NAME}.* TO '${NEXTCLOUD_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

    # Download and extract Nextcloud in a working directory (/tmp).
    echo "Downloading Nextcloud..."
    cd /tmp
    sudo wget -O latest.zip https://download.nextcloud.com/server/releases/latest.zip

    echo "Extracting Nextcloud..."
    sudo unzip -o latest.zip

    # Remove any existing Nextcloud installation in the target directory.
    if [ -d "${NEXTCLOUD_DIR}" ]; then
        sudo rm -rf "${NEXTCLOUD_DIR}"
    fi

    echo "Installing Nextcloud..."
    sudo mv nextcloud "${NEXTCLOUD_DIR}"
    sudo mkdir -p "${NEXTCLOUD_DIR}/data"
    sudo chown -R apache:apache "${NEXTCLOUD_DIR}"
    
    # Install Nextcloud via the occ command.
    sudo -u apache php "${NEXTCLOUD_DIR}/occ" maintenance:install \
      --database "mysql" \
      --database-name "${NEXTCLOUD_DB_NAME}" \
      --database-user "${NEXTCLOUD_DB_USER}" \
      --database-pass "${NEXTCLOUD_DB_PASSWORD}" \
      --admin-user "${NEXTCLOUD_ADMIN_USER}" \
      --admin-pass "${NEXTCLOUD_ADMIN_PASS}"
fi

#------------------------------------------------------------------------------
# Apache VirtualHost Configuration for Nextcloud
#------------------------------------------------------------------------------
if [ ! -f "${VHOST_CONF}" ]; then
    echo "Creating Apache VirtualHost configuration for Nextcloud..."
    sudo tee "${VHOST_CONF}" > /dev/null <<EOL
<VirtualHost *:80>
    ServerName ${MY_IP}
    DocumentRoot ${NEXTCLOUD_DIR}

    <Directory ${NEXTCLOUD_DIR}>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>

    ErrorLog /var/log/httpd/nextcloud_error.log
    CustomLog /var/log/httpd/nextcloud_access.log combined
</VirtualHost>
EOL
# Remove default Apache index page if it exists.
if [ -f "/var/www/html/index.html" ]; then
        sudo rm -f /var/www/html/index.html
    fi
    sudo systemctl restart httpd
fi

#------------------------------------------------------------------------------
# Post-installation / Always-run Tasks
#------------------------------------------------------------------------------

# Install and enable Nextcloud Calendar and Forms apps.
echo "Installing and enabling additional Nextcloud apps (Calendar and Forms)..."
APPS=("calendar" "forms")
for app in "${APPS[@]}"; do
    echo "Installing the ${app} app..."
    sudo -u apache php "${NEXTCLOUD_DIR}/occ" app:install "$app" 2>/dev/null || \
      echo "Notice: ${app} app may already be installed or encountered an error."
    echo "Enabling the ${app} app..."
    sudo -u apache php "${NEXTCLOUD_DIR}/occ" app:enable "$app" 2>/dev/null || \
      echo "Notice: ${app} app may already be enabled or encountered an error."
done

# Configure firewall rules.
echo "Updating firewall settings..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Configure Nextcloud trusted domains.
echo "Configuring trusted domains for Nextcloud..."
cd "${NEXTCLOUD_DIR}"
sudo -u apache php occ config:system:set trusted_domains 0 --value="nextcloud.g07-syndus.internal"
sudo -u apache php occ config:system:set trusted_domains 1 --value="${MY_IP}"

echo "Provisioning complete"