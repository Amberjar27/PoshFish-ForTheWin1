#!/bin/bash

##########################################################
# Created all by Karl [CCDC 2023]. Modify by Tien Nguyen #
# Took FROM part of it from porygon 					           #								
# Description: ADD firewall rules and logging            #
#														                             #		
##########################################################

  iptables -F
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT
  iptables -A INPUT -p udp --dport 123 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT 
  iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 1514 -j ACCEPT
  iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j DROP
  iptables -A OUTPUT -p tcp --dport 22 -m state --state ESTABLISHED -j DROP
  iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT DROP


  echo '*.* @172.20.241.20:1514' | sudo tee -a /etc/rsyslog.conf > /dev/null && sudo systemctl restart rsyslog