#!/bin/bash

# Update system and install packages
apt update && apt upgrade -y
apt install vim bind9 isc-dhcp-server -y

# Enable routing
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
/usr/sbin/sysctl -p

# Setup static IP for LAN interface
/usr/bin/cat << EOF > /etc/network/interfaces.d/eth1
allow-hotplug eth1
iface eth1 inet static
    address 192.168.151.10
    netmask 255.255.255.0
EOF

# Bring up the interface immediately
ifup eth1

# Setup Bind/DNS
/usr/bin/cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    listen-on port 53 { any; };
    allow-query { any; };
    recursion yes;
    dnssec-validation no;
    forwarders {
        1.1.1.1;
    };
    forward only;
};
EOF

systemctl enable named
systemctl start named

# Enable NAT'ing
systemctl enable nftables
systemctl start nftables

/usr/bin/cat << EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
    }
    chain forward {
        type filter hook forward priority 0;
    }
    chain output {
        type filter hook output priority 0;
    }
}

table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100;
    }
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "eth0" masquerade
    }
}
EOF

# Configure and enable DHCP
/usr/bin/cat << EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth1"
EOF

/usr/bin/cat << EOF > /etc/dhcp/dhcpd.conf
option domain-name "hogent.local";
option domain-name-servers 192.168.151.7;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

subnet 192.168.151.0 netmask 255.255.255.0 {
    range 192.168.151.100 192.168.151.200;
    option routers 192.168.151.10;
    option subnet-mask 255.255.255.0;
}
EOF

# Restart services to apply changes
systemctl restart nftables
systemctl restart isc-dhcp-server
systemctl restart bind9

reboot