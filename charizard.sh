#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo "Configuring iptables firewall..."

# Flush existing rules
iptables -F
iptables -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback (localhost) traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming SMTP traffic
iptables -A INPUT -p tcp –dport 25 -j ACCEPT
iptables -A INPUT -p tcp --dport 587 -j ACCEPT
iptables -A INPUT -p tcp --dport 465 -j ACCEPT

# Allow incoming IMAP and POP3 traffic
iptables -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -j ACCEPT
iptables -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -A INPUT -p tcp --dport 995 -j ACCEPT

# Allow web traffic (HTTP/HTTPS)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow DNS traffic
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# Allow NTP traffic
iptables -A INPUT -p udp --dport 123 -d 172.20.241.20 -j ACCEPT

# Allow rsyslog traffic
iptables -A OUPTUT -p tcp --dport 1514 -d 172.20.241.20 -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Save iptables rules
echo "Saving iptables rules..."
service iptables save

# Restart iptables service
echo "Restarting iptables service..."
systemctl restart iptables

echo "Firewall configuration complete!"
