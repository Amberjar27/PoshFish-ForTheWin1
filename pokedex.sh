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
defaultPolicy(){
  iptables --policy INPUT DROP
  iptables --policy FORWARD DROP
  iptables --policy OUTPUT DROP
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
}

# Allow web browsing
allowWebBrowsing(){
  iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
}

# Rule for a DNS/NTP clients
allowDNSNTPclient(){
  iptables -A OUTPUT -p tcp --dport 53 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
}

# Rules for HIDS clients
allowHIDSClient(){
  iptables -A OUTPUT -p tcp --dport 1514 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Agent connection
  iptables -A OUTPUT -p udp --dport 1514 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Agent connection
  iptables -A OUTPUT -p tcp --dport 1515 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Agent enrollment
  iptables -A OUTPUT -p tcp --dport 514 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Syslog collector
  iptables -A OUTPUT -p udp --dport 514 -d $1 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT  #Syslog collector
}

# Rule for a syslog clients
allowSysLog(){
  read -p "Enter IP address for Splunk server" sip
  iptables -A OUTPUT -p tcp --dport 9997 -d $sip -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 9998 -d $sip -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 601 -d $sip -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 514 -d $sip -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
}

allowICMP(){
  iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
  iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
}

flushFirewall(){
  iptables -F
  iptables --policy INPUT ACCEPT
  iptables --policy FORWARD ACCEPT
  iptables --policy OUTPUT ACCEPT
  echo -e -n "${RED}"
  iptables -L
  echo "Firewall rules removed, default policy set to ACCEPT user beware!"
  echo -e "${RESET}"
}

showFirewall(){
  echo -e -n "${GREEN}"
  echo -e "...DONE"
  echo -e -n "${CYAN}"
  iptables -L --line-numbers
  echo -e "${RESET}"
}

setDNS-NTP(){
  defaultPolicy
  allowWebBrowsing
  allowICMP
  iptables -A INPUT -p tcp --sport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --sport 953 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp --sport 953 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 953 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 953 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  iptables -A INPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  allowSysLog   # Allows syslogs to be forwarded to datalake
  showFirewall  # Lists firewall rules applied to the system
}

while getopts 'dfijs :' OPTION; do
  case "$OPTION" in
    d)
      echo "Appling firewall rules for DNS-NTP..."
      setDNS-NTP
      ;;
    f)
      echo "Removing all firewall rules..."
      flushFirewall
      ;;
    i)
      read -p "Enter IP address for HIDS server" hip
      echo "Applying firewall rules for HIDS clients"
      allowHIDSClient $hip
      ;;
    j)
      read -p "Enter network IP address for HIDS clients" hip
      echo "Applying firewall rules for HIDS server"
      allowHIDSserver $hip
      ;;
    s)
      echo "Applying secure firewall rules..."
      defaultPolicy
      allowWebBrowsing
      showFirewall
      ;;
    ?)
      echo -e -n "${YELLOW}"
      echo -e "Correct usage:\t $(basename $0) -flag(s)"
      echo -e "-d\t Applies firewall rules for DNS/NTP"
      echo -e "-f\t Deletes all firewall rules"
      echo -e "-i\t Applies firewall rules for HIDS clients"
      echo -e "-j\t Applies firewall rules for HIDS server"
      echo -e "-h\t or any unlisted flag returns this message."
      echo -e "${RESET}"
      exit 1
      ;;
  esac
done
