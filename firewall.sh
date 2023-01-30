#! /bin/bash
################################################################################
# Written by: K7-Avenger & previous MetroCCDC team member(s)                   #
# For: Metro State CCDC 2023                                                   #
# Purpose: To set appropriate firewall (iptables) rules for linux hosts and    #
# add logging rules which may indicate a particular host is activly under      #
# attack.                                                                      #
################################################################################

#NEED TO ADD POLICY CHANGES. THIS CAN BE DONE WITH -P. DO NOT FORGET FORWARD CHAIN FOR POLICIES - Darien

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Drops attempted connections on ports not already explicityly defined as ACCEPT
dropAll(){
  iptables -A INPUT -j DROP
}

logFirewallEvents(){
  iptables -A INPUT -p tcp ! --syn -m state --state NEW -m limit --limit 1/min -j LOG --log-prefix "SYN packet flood: "
  iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
  iptables -A INPUT -f -m limit --limit 1/min -j LOG --log-prefix "Fragmented packet: "
  iptables -A INPUT -f -j DROP
  iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/min -j LOG --log-prefix "XMAS packet: "
  iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
  iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/min -j LOG --log-prefix "NULL packet: "
  iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
  iptables -A INPUT -p icmp -m limit --limit 1/minute -j LOG --log-prefix "ICMP Flood: "
  iptables -A INPUT -p icmp -m limit --limit 3/sec -j ACCEPT
  iptables -A OUTPUT -p icmp -m limit --limit 3/sec -j ACCEPT
  iptables -A FORWARD -f -m limit --limit 1/min -j LOG --log-prefix "Hacked Client "
  iptables -A FORWARD -p tcp --dport 31337:31340 --sport 31337:31340 -j DROP
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT
  iptables -A OUTPUT -m limit --limit 2/min -j LOG --log-prefix "Output-Dropped: " --log-level 4
  iptables -A INPUT -m limit --limit 2/min -j LOG --log-prefix "Input-Dropped: " --log-level 4
  iptables -A FORWARD -m limit --limit 2/min -j LOG --log-prefix "Forward-Dropped: " --log-level 4
}

allowSysLog(){
  iptables -A OUTPUT -p tcp --dport 9997 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 601 -j ACCEPT
}

showFirewall(){
  echo -e -n "${GREEN}"
  echo -e "...DONE"
  echo -e -n "${CYAN}"
  iptables -L --line-numbers
  echo -e "${RESET}"
}

flushFirewall(){
#should remove chains with -X option, as you only need the default ones
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
  allowSysLog   # Allows syslogs to be forwarded to datalake
  dropAll       # Opens the required ports for syslogs to be forwarded to datalake
  showFirewall  # Lists firewall rules applied to the system
}

setEcom(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -j ACCEPT # Required to sync with NTP
  allowSysLog                                     # Allows syslogs to be forwarded to datalake
  dropAll                                         # Opens the required ports for syslogs to be forwarded to datalake
  showFirewall                                    # Lists firewall rules applied to the system
}

setWebmail(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 25 -j ACCEPT
  iptables -A INPUT -p tcp --dport 110 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -j ACCEPT # Required to sync with NTP
  allowSysLog                                     # Opens the required ports for syslogs to be forwarded to datalake
  dropAll                                         # Closes all ports not already explicitly set to ACCEPT
  showFirewall                                    # Lists firewall rules applied to the system
}

setPaloWS(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  iptables -A INPUT -p tcp --dport 8000 -d $2 -j ACCEPT
  iptables -A INPUT -p tcp --dport 22 -d $1 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT 
  iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -d $3 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 22 -d $1 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -d $3 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 8000 -d $2 -j ACCEPT
  allowSysLog   # Opens the required ports for syslogs to be forwarded to datalake
  dropAll
  showFirewall
}

while getopts 'dewfp :' OPTION; do
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
    p)
      echo "Applying firewall rules for Palo Workstation"
      read -p "Enter Palo IP address: " pip
      read -p "Enter SIEM IP: " sip
      read -p "Enter DNS IPL " dip
      setPaloWS $pip $sip $dip
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
      echo -e "-p\t Applies firewall rules for Palo"
      echo -e "-h\t or any unlisted flag returns this message."
      echo -e "${RESET}"
      exit 1
      ;;
  esac
done

# logFirewallEvents was stolen from previous MetroCCDC scripts & still needs testing ~ DW
# setPaloWS needs to be tested ~ NO
