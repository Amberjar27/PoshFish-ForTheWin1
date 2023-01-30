#!/bin/bash

################################################################################
# Written by: K7-Avenger						       #
# For: Metro State CCDC 2023                                                   #
# Purpose: To configure NTP on client & servers to meet predetermined criteria #
################################################################################

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

debianClient(){
	sudo apt-get install ntp -y --allow-unauthenticated	# Should allow for uninterupted insallation of NTP
	
	mv /etc/ntp.conf /etc/ntp.conf.orig			# Preserves the origanals files by renaming them
	
	touch /etc/ntp.conf					# Creates blanks file to be used for NTP client configs

	# Begin writes to new ntp configuration files
	echo "NTPD_OPTS='-4 -g'" > /etc/default/ntp
	
	echo "driftfile /var/lib/ntp/ntp.drift" >> /etc/ntp.conf
	echo "statistics loopstats peerstats clockstats" >> /etc/ntp.conf
	echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf
	echo "filegen peerstats file peerstats type day enable" >> /etc/ntp.conf
	echo "filegen clockstats file clockstats type day enable" >> /etc/ntp.conf

	echo "# LAN NTP source" >> /etc/ntp.conf
	echo " server $1 iburst prefer" >> /etc/ntp.conf

	echo " By default, exchange time with everyone, but don't allow configuration" >> /etc/ntp.connf
	echo "restrict -4 default kod notrap nomodify nopeer noquery" >> /etc/ntp.connf
	echo "restrict 127.0.0.1" >> /etc/ntp.connf
	
	# Finish sysetm configs
	timedatectl set-ntp false
	
	# Restart ntp service
	service ntp restart
	ntpdate -u $1
	echo "Capture a screenshot of the following output for a potential inject.\nOtherwise referr to 'NTP Client configuration' by DW for inject steps.\n"
	ntpq -pn -4
}

#centOsClient(){
#}

#serverConfig(){
#}

while getopts 'ucs :' OPTION; do
  case "$OPTION" in
    u)
      read -p "Enter the IPv4 address of the servper providing NTP:" ntpIP
      echo -e "Applying NTP configs for Debian/Ubuntu clients...\n"
      debianClient $ntpIP
      ;;
    c)
      echo "Applying NTP configs for CentOS/Fedora clients..."
      centOsClient
      ;;
    s)
      echo "Applying NTP configs for NTP server..."
      serverConfig
      ;;
    ?)
      echo -e -n "${YELLOW}"
      echo -e "Correct usage:\t $(basename $0) {IPv4 addr of NTP server} -flag(s)"
      echo -e "-u\t Applies NTP configs for Debian/Ubuntu clients"
      echo -e "-c\t Applies NTP configs for CentOS/Fedora clients"
      echo -e "-s\t Applies NTP configs for NTP server"
      echo -e "${RESET}"
      exit 1
      ;;
  esac
done
