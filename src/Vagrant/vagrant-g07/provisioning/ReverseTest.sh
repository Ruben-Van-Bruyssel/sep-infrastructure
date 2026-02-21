#! /bin/bash
#
# Provisioning script for ReverseProxy

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------
# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
headers_config="/headers/headers-more-nginx-module"
config_file="/etc/nginx/conf.d/g07-syndus.internal.conf"
config_file_extra="/etc/nginx/conf.d/extra.conf"
config_file_nextcloud="/etc/nginx/conf.d/nextcloud.g07-syndus.internal.conf"
config_file_jellyfin="/etc/nginx/conf.d/jellyfin.g07-syndus.internal.conf"
config_file_matrix="/etc/nginx/conf.d/matrix.g07-syndus.internal.conf"
cert_path="/etc/ssl/certs/myCertificate.crt"
key_path="/etc/ssl/certs/myKey.key"
webserver_ip="192.168.151.60"
redundant_webserver_ip="192.168.151.62"
#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

# Disable ssh password login and root login
#sudo sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

#C compiler voor download
sudo dnf install gcc pcre-devel zlib-devel openssl-devel -y

# Dit gedeelte van het script configureert SELinux voor je NGINX reverse proxy.
# Voer dit uit als root en zorg dat 'set -o errexit -o nounset -o pipefail' is ingeschakeld.


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

# 3. Controleer of de Nginx HTML-directory bestaat; maak deze indien nodig aan
NGINX_HTML_DIR="/usr/share/nginx/html"
if [ ! -d "$NGINX_HTML_DIR" ]; then
    echo "Map $NGINX_HTML_DIR bestaat niet. Deze wordt nu aangemaakt..."
    sudo mkdir -p "$NGINX_HTML_DIR"
fi

# Herstel de SELinux-contexten voor deze directory
echo "Herstel SELinux-contexten voor $NGINX_HTML_DIR..."
sudo restorecon -Rv "$NGINX_HTML_DIR"

sudo chown -R nobody:nobody /usr/share/nginx/html
sudo chmod -R 755 /usr/share/nginx/html

# 4. Maak een placeholder aan voor de custom error-pagina (custom_50x.html)
CUSTOM_ERROR_FILE="$NGINX_HTML_DIR/custom_50x.html"
if [ ! -f "$CUSTOM_ERROR_FILE" ]; then
    echo "Bestand $CUSTOM_ERROR_FILE bestaat niet. Maak een placeholder aan..."
    sudo tee "$CUSTOM_ERROR_FILE" > /dev/null <<EOF
<html>
  <head>
    <title>Server Error</title>
  </head>
  <body>
    <h1>Er is een fout opgetreden</h1>
    <p>De server heeft een interne fout gedetecteerd.</p>
  </body>
</html>
EOF
    # Herstel de SELinux-context ook voor het aangemaakte bestand
    sudo restorecon -v "$CUSTOM_ERROR_FILE"
fi

echo "SELinux-configuratie aangevuld: Nginx mag nu uitgaande verbindingen maken via HTTP en HTTPS, en het custom error-bestand is aanwezig."
echo "Herlaad of herstart Nginx om de wijzigingen in werking te laten treden."
#


#nginx compilen met module file
 wget 'http://nginx.org/download/nginx-1.21.4.tar.gz'
 tar -xzvf nginx-1.21.4.tar.gz
 cd nginx-1.21.4/

 #adding module
 wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.37.tar.gz
 tar -xzvf v0.37.tar.gz

# Ensure the destination directory exists and handle existing files
mkdir -p /nginx-1.21.4/src/http/modules
if [ ! -d /nginx-1.21.4/src/http/modules/headers-more-nginx-module-0.37 ]; then
    sudo mv headers-more-nginx-module-0.37 /nginx-1.21.4/src/http/modules/
else
    echo "Module already exists in the destination directory. Skipping move."
fi

# Configure, build, and install Nginx
./configure --prefix=/etc/nginx --add-module=/nginx-1.21.4/src/http/modules/headers-more-nginx-module-0.37 --with-http_ssl_module --with-http_v2_module
make
sudo make install

sudo chown -R nobody:nobody /etc/nginx
sudo find /etc/nginx -type f -exec chmod 644 {} \;
sudo find /etc/nginx -type d -exec chmod 755 {} \;
sudo chmod 755 /etc/nginx/sbin/nginx


#making service
 cat <<EOF > "/etc/systemd/system/nginx.service"
 [Unit]
Description=nginx - high performance web server
After=network.target

[Service]
Type=forking
ExecStart=/etc/nginx/sbin/nginx
ExecReload=/etc/nginx/sbin/nginx -s reload
ExecStop=/etc/nginx/sbin/nginx -s stop
PIDFile=/etc/nginx/logs/nginx.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload

# Firewall

sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=53/udp --permanent


sudo firewall-cmd --reload

#Tls keys

sudo mkdir -p /etc/ssl/certs
chmod 700 /etc/ssl/certs

sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -keyout "$key_path" -out  "$cert_path" \
    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=g07-syndus.internal"

sudo chmod 600 /etc/ssl/certs/myKey.key /etc/ssl/certs/myCertificate.crt


# Prevent nmap from giving information
#sed -i '/http {/a \    server_tokens off;' /etc/nginx/nginx.conf


sudo systemctl start nginx

systemctl enable --now nginx

# Create /etc/nginx/certs directory only if it doesn't exist
if [ ! -d /etc/nginx/certs ]; then
    sudo mkdir -p /etc/nginx/certs
    echo "Directory /etc/nginx/certs created."
else
    echo "Directory /etc/nginx/certs already exists. Skipping creation."
fi

# Create /etc/nginx/conf.d directory only if it doesn't exist
if [ ! -d /etc/nginx/conf.d ]; then
    sudo mkdir -p /etc/nginx/conf.d
    echo "Directory /etc/nginx/conf.d created."
else
    echo "Directory /etc/nginx/conf.d already exists. Skipping creation."
fi

#making nginx config file
sudo touch /access.log
sudo rm /etc/nginx/conf/nginx.conf -f
cat <<EOF > "/etc/nginx/conf/nginx.conf"
worker_processes auto;
# pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    use epoll;  # Efficient handling of connections on Linux
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   20s;
    types_hash_max_size 2048;
    server_tokens       off;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_stapling off;
    ssl_stapling_verify off;
    resolver 192.168.151.7 valid=300s;  # External resolver for OCSP stapling

    # Custom server header for security through obscurity
    more_set_headers 'Server: Apache';

    # Rate limiting setup
    limit_req_zone \$binary_remote_addr zone=one:10m rate=5r/s;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    #add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://trustedscripts.example.com;";
    
    #access_log /access.log;
    include /etc/nginx/conf.d/*.conf;  # Include all external server blocks

}
EOF

# Hoofd serverblok
cat <<EOF > "$config_file"
upstream backend_main {
    server $webserver_ip;
    server $redundant_webserver_ip;
}

server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name g07-syndus.internal www.g07-syndus.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    # ssl_client_certificate uitgeschakeld
    # ssl_verify_client off;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
        root /usr/share/nginx/html;
        internal;
    }

    location / {
        proxy_pass http://backend_main;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
    # Logging
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
}
EOF

# Extra serverblok
cat <<EOF > "$config_file_extra"
upstream backend_extra {
    server $webserver_ip;
    server $redundant_webserver_ip;
    # server [2001:db8:ac03:42::FFFB];
    # server [2001:db8:ac03:42::FFF7];
}

server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name extra.g07-syndus.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    # ssl_client_certificate uitgeschakeld
    # ssl_verify_client off;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
        root /usr/share/nginx/html;
        internal;
    }

    location / {
        proxy_pass http://backend_extra;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
    # Logging
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
}
EOF


# Nextcloud server block
cat <<EOF > "$config_file_nextcloud"
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name nextcloud.g07-syndus.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    # ssl_client_certificate uitgeschakeld
    # ssl_verify_client off;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://192.168.151.55;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
}
EOF

# jellyfin server block
cat <<EOF > "$config_file_jellyfin"
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name jellyfin.g07-syndus.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    # ssl_client_certificate uitgeschakeld
    # ssl_verify_client off;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://192.168.151.61;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
}
EOF

# matrix server block
cat <<EOF > "$config_file_matrix"
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name matrix.g07-syndus.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    # ssl_client_certificate uitgeschakeld
    # ssl_verify_client off;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://192.168.207.63;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
    # Logging
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
}
EOF

# Set the correct DNS server
DNS_SERVER="192.168.151.7"

echo "Updating DNS configuration..."
sudo sed -i "/^nameserver /c\nameserver $DNS_SERVER" /etc/resolv.conf


sudo systemctl restart nginx

# Ensure the hostname is correctly mapped
if ! grep -q "192.168.151.60 www.g07-syndus.internal" /etc/hosts; then
    echo "192.168.151.60 www.g07-syndus.internal" | sudo tee -a /etc/hosts
    echo "Added g07-syndus.internal to /etc/hosts"
fi



# Test hostname resolution
curl -k https://www.g07-syndus.internal || { echo "Failed to resolve g07-syndus.internal"; exit 1; }

# Configure SELinux policies for Nginx
sudo cat /var/log/audit/audit.log | grep nginx | audit2allow -m nginx_custom > nginx_custom.te
sudo checkmodule -M -m -o nginx_custom.mod nginx_custom.te
sudo semodule_package -o nginx_custom.pp -m nginx_custom.mod
sudo semodule -i nginx_custom.pp

#restarts
#sudo systemctl restart httpd
sudo systemctl restart nginx

