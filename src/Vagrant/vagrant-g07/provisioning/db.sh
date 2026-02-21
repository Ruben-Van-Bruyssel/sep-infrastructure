#!/bin/bash
#
# Provisioning script for database server with enhanced security

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------
set -euo pipefail  # Strict mode: exit on errors, undefined variables, or pipe failures

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
readonly DB_ROOT_PASSWORD="password"
readonly DB_NAME="wordpress_db"
readonly DB_TABLE="syndus_tbl"
readonly DB_USER="db-wp-user"
readonly DB_PASSWORD="6Qow9FjS6jttmbdp4e981aXMh"
readonly WEB_SERVER_IP="192.168.151.60"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------
log() {
    echo "[LOG] $1"
}

is_mysql_root_password_empty() {
    mysql -uroot -e "SELECT 1" &> /dev/null
}

#------------------------------------------------------------------------------
# Start Provisioning
#------------------------------------------------------------------------------
log "=== Starting server provisioning on ${HOSTNAME} ==="

#------------------------------------------------------------------------------
# Install & Configure MariaDB
#------------------------------------------------------------------------------
log "Adding MariaDB repository..."
curl -sSL https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash

log "Installing MariaDB server..."
dnf install -y MariaDB-server MariaDB-client

log "Enabling and starting MariaDB service..."
systemctl enable --now mariadb.service

# Secure MariaDB to listen on all interfaces but restrict access via firewall
log "Configuring MariaDB to accept connections from web server..."
echo "[mysqld]" | tee -a /etc/my.cnf.d/mariadb-server.cnf
echo "bind-address=0.0.0.0" | tee -a /etc/my.cnf.d/mariadb-server.cnf
systemctl restart mariadb

#------------------------------------------------------------------------------
# Configure Firewall
#------------------------------------------------------------------------------
log "Configuring firewall..."

# Install and enable firewalld if not already present
if ! rpm -q firewalld &>/dev/null; then
    dnf install -y firewalld
    systemctl enable --now firewalld
else
    log "firewalld is already installed"
fi

log "Setting firewall rules..."
sudo systemctl start firewalld
# Keep SSH access open
firewall-cmd --permanent --add-service=ssh

# Add specific rich rule for MySQL port from web server only
firewall-cmd --permanent --add-rich-rule="\
    rule family='ipv4' \
    source address='${WEB_SERVER_IP}' \
    port port='3306' protocol='tcp' \
    accept"
# Reload firewall to apply changes
if firewall-cmd --reload; then
    log "Firewall rules successfully applied"
else
    log "ERROR: Failed to reload firewall" >&2
    exit 1
fi

# Verify the rules were applied
log "Current firewall rules:"
firewall-cmd --list-all
#------------------------------------------------------------------------------
# Secure Database
#------------------------------------------------------------------------------
log "Securing MariaDB..."
if is_mysql_root_password_empty; then
    mariadb -uroot <<_EOF_
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
_EOF_
    log "Root password set and unnecessary users/databases removed."
else
    log "Root password is already set. Skipping security steps."
fi

#------------------------------------------------------------------------------
# Create Database & User
#------------------------------------------------------------------------------
log "Creating database and user..."
mariadb -uroot -p"${DB_ROOT_PASSWORD}" <<_EOF_
    CREATE DATABASE IF NOT EXISTS ${DB_NAME};
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'%';
    FLUSH PRIVILEGES;
_EOF_

#------------------------------------------------------------------------------
# Create Table & Insert Sample Data
#------------------------------------------------------------------------------
log "Creating database table and inserting sample data..."
mariadb -u"${DB_USER}" -p"${DB_PASSWORD}" -h"localhost" "${DB_NAME}" <<_EOF_
    CREATE TABLE IF NOT EXISTS ${DB_TABLE} (
        id INT(5) NOT NULL AUTO_INCREMENT,
        name VARCHAR(50) DEFAULT NULL,
        PRIMARY KEY(id)
    );
    INSERT INTO ${DB_TABLE} (id, name) VALUES (1, "Tuxedo T. Penguin")
        ON DUPLICATE KEY UPDATE name=VALUES(name);
    INSERT INTO ${DB_TABLE} (id, name) VALUES (2, "Bobby Tables")
        ON DUPLICATE KEY UPDATE name=VALUES(name);
_EOF_

log "Database setup complete!"