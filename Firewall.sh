#! /bin/bash

denyAll(){
  iptables -A INPUT -j DROP
}
showFirewall(){
  iptables -L --line-numbers
}
flushFirewall(){
  iptables -F
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
  iptables -A INPUT -p udp --dport 123 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
  denyAll
  showFirewall
}

setEcom(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
# May also need TCP-443 opened, check with Ecomm  
  denyAll
  showFirewall
}

setWebmail(){
  iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --dport 25 -j ACCEPT
  iptables -A INPUT -p tcp --dport 110 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
  denyAll
  showFirewall
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
      echo -e "Correct usage:\t $(basename $0) -flag(s)"
      echo -e "-d\t Applies firewall rules for DNS/NTP"
      echo -e "-e\t Applies firewall rules for E-com"
      echo -e "-w\t Applies firewall rules for Webmail"
      echo -e "-f\t Deletes all firewall rules"
      echo -e "-h\t or any unlisted flag returns this message."
      exit 1
      ;;
  esac
done