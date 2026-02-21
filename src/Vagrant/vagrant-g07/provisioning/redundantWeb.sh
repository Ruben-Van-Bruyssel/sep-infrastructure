#!/bin/bash
#
# Provisioning script for web server
#

set -euo pipefail

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

# Function for logging messages
log() {
    echo "[INFO] $1"
}

log "Starting web server provisioning..."

#------------------------------------------------------------------------------
# Install Apache and PHP
#------------------------------------------------------------------------------
log "Checking if Apache is already installed..."
if ! rpm -q httpd &>/dev/null; then
    log "Installing Apache..."
    dnf install -y httpd
else
    log "Apache is already installed."
fi

log "Installing PHP 8.3 and required extensions..."
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module reset php -y
dnf module enable php:remi-8.3 -y
dnf install -y php php-mysqlnd php-gd php-xml php-mbstring php-opcache php-json php-curl php-zip

# Enable and start Apache
log "Enabling and starting Apache..."
systemctl enable --now httpd

#------------------------------------------------------------------------------
# Configure firewall for HTTP traffic
#------------------------------------------------------------------------------
log "Checking if firewalld is installed and running..."
if ! systemctl is-active --quiet firewalld; then
    log "Installing and starting firewalld..."
    dnf install -y firewalld
    systemctl enable --now firewalld
else
    log "firewalld is already running."
fi

log "Configuring firewall rules for HTTP traffic..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

#------------------------------------------------------------------------------
# Set SELinux permissions for Apache
#------------------------------------------------------------------------------
log "Setting SELinux permissions for Apache..."
setsebool -P httpd_can_network_connect_db 1
setsebool -P httpd_can_network_connect 1

# Ensure correct SELinux context
log "Adjusting SELinux context for web directory..."
restorecon -Rv /var/www/html

#------------------------------------------------------------------------------
# Set up document root and database connection
#------------------------------------------------------------------------------
WEB_DIR="/var/www/html"
DB_HOST="192.168.151.52"
DB_USER="db-wp-user"
DB_PASS="6Qow9FjS6jttmbdp4e981aXMh"
DB_NAME="wordpress_db"

log "Setting up web server document root and database connection..."

#------------------------------------------------------------------------------
# Download and extract WordPress
#------------------------------------------------------------------------------
if [ ! -f "$WEB_DIR/wp-config.php" ]; then
    log "Downloading WordPress..."
    wget -q -O /tmp/wordpress.tar.gz "https://wordpress.org/latest.tar.gz"
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    cp -r /tmp/wordpress/* ${WEB_DIR}/
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz

    # Set permissions for WordPress
    log "Setting permissions for WordPress directories..."
    chown -R apache:apache "$WEB_DIR"
    chmod -R 755 "$WEB_DIR"
    find "$WEB_DIR" -type d -exec chmod 755 {} \;
    find "$WEB_DIR" -type f -exec chmod 644 {} \;
else
    log "WordPress is already installed. Skipping download."
fi

#------------------------------------------------------------------------------
# Configure WordPress
#------------------------------------------------------------------------------
log "Creating WordPress configuration file..."
cp "$WEB_DIR/wp-config-sample.php" "$WEB_DIR/wp-config.php"

# Escape special characters in database credentials
DB_NAME_ESCAPED=$(echo "$DB_NAME" | sed 's/[\/&]/\\&/g')
DB_USER_ESCAPED=$(echo "$DB_USER" | sed 's/[\/&]/\\&/g')
DB_PASS_ESCAPED=$(echo "$DB_PASS" | sed 's/[\/&]/\\&/g')
DB_HOST_ESCAPED=$(echo "$DB_HOST" | sed 's/[\/&]/\\&/g')

log "Configuring WordPress database settings..."
sed -i "s/database_name_here/$DB_NAME_ESCAPED/" "$WEB_DIR/wp-config.php"
sed -i "s/username_here/$DB_USER_ESCAPED/" "$WEB_DIR/wp-config.php"
sed -i "s/password_here/$DB_PASS_ESCAPED/" "$WEB_DIR/wp-config.php"
sed -i "s/localhost/$DB_HOST_ESCAPED/" "$WEB_DIR/wp-config.php"

# Set file system method to direct
log "Setting file system method to direct..."
echo "define('FS_METHOD', 'direct');" >> "$WEB_DIR/wp-config.php"

# Generate secure authentication keys
log "Generating secure authentication keys..."
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> "$WEB_DIR/wp-config.php"

# Enable debugging mode (optional)
log "Enabling WordPress debugging..."
echo "define('WP_DEBUG', true);" >> "$WEB_DIR/wp-config.php"
echo "define('WP_DEBUG_LOG', true);" >> "$WEB_DIR/wp-config.php"

#------------------------------------------------------------------------------
# Restart Apache
#------------------------------------------------------------------------------
log "Restarting Apache to apply changes..."
systemctl restart httpd

log "WordPress installation complete! Access it at http://g07-syndus.internal/"
