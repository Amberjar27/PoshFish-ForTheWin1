#! /bin/bash

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;35m'
RESET='\033[0m'

denyAll(){
  iptables -A INPUT -j DROP
}
showFirewall(){
  echo -e -n "${CYAN}"
  echo -e "...DONE"
  iptables -L --line-numbers
  echo -e "${RESET}"
}
flushFirewall(){
  iptables -F
  echo -e -n "${RED}"
  echo "Firewall rules removed, user beware!"
  echo -e "${RESET}"
}
allowNTP(){
  iptables -A INPUT -p udp --dport 123 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
}

setDNS-NTP(){
  iptables -A INPUT -p tcp --dport 53 -j ACCEPT
  iptables -A INPUT -p tcp --dport 953 -j ACCEPT
  iptables -A INPUT -p udp --dport 53 -j ACCEPT
  iptables -A INPUT -p udp --dport 953 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 953 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 953 -j ACCEPT
  allowNTP      # Required to provide NTP services
  denyAll       # Closes all ports not already explicitly set to ACCEPT
  showFirewall  # Lists firewall rules applied to the system
}

setEcom(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
  allowNTP      # Required to sync with NTP
  denyAll       # Closes all ports not already explicitly set to ACCEPT
  showFirewall  # Lists firewall rules applied to the system
}

setWebmail(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 25 -j ACCEPT
  iptables -A INPUT -p tcp --dport 110 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
  allowNTP      # Required to sync with NTP
  denyAll       # Closes all ports not already explicitly set to ACCEPT
  showFirewall  # Lists firewall rules applied to the system
}

while getopts 'dewf :' OPTION; do
  case "$OPTION" in
    d)
      echo "Appling firewall rules for DNS-NTP..."
      setDNS-NTP
      ;;
    e)
      echo "Applying firewall rules for E-com..."
      setEcom
      ;;
    w)
      echo "Applying firewall rules for webmail..."
      setWebmail
      ;;
    f)
      echo "Removing all firewall rules..."
      flushFirewall
      ;;
    ?)
      echo -e -n "${YELLOW}"
      echo -e "Correct usage:\t $(basename $0) -flag(s)"
      echo -e "-d\t Applies firewall rules for DNS/NTP"
      echo -e "-e\t Applies firewall rules for E-com"
      echo -e "-w\t Applies firewall rules for Webmail"
      echo -e "-f\t Deletes all firewall rules"
      echo -e "-h\t or any unlisted flag returns this message."
      echo -e "${RESET}"
      exit 1
      ;;
  esac
done
