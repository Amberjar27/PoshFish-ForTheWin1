#!/bin/bash
################################################################################
# Written by: K7-Avenger, previous & current MetroCCDC team member(s)          #
# For: Metro State CCDC 2023-2024                                              #
# Purpose: To set appropriate firewall (iptables) rules for linux hosts and    #
# add logging rules which may indicate a particular host is activly under      #
# attack.                                                                      #
################################################################################

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Sets the default policy to drop any attempted connections not explicitly 
# allowed by other rules
dropAll(){
  iptables --policy INPUT DROP
  iptables --policy FORWARD DROP
  iptables --policy OUTPUT DROP
}

# Allows all incoming connections that are self-initiated 
allowSelf-started(){
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
}

# Allows connections on the loopback adapter
allowLoopback(){
  iptables -A OUTPUT -o lo -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
}

# Allow web browsing
enableWebBrowsing(){
  iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
}

# Rule for a DNS client (still needs DNS server identification)
enableDNSclient(){
  iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
}

# Rules for Wazuh clients needs Wazuh server identification
enableWazuhClient(){
  iptables -A OUTPUT -p tcp --dport 1514 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Agent connection
  iptables -A OUTPUT -p udp --dport 1514 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Agent connection
  iptables -A OUTPUT -p tcp --dport 1515 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Agent enrollment
  iptables -A OUTPUT -p tcp --dport 514 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Syslog collector
  iptables -A OUTPUT -p udp --dport 514 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Syslog collector
}
