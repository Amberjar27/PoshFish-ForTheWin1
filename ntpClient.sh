#!/bin/bash

debianBase(){
	sudo apt-get install ntp -y --allow-unauthenticated		# Should allow for uninterupted insallation of NTP
	mv /etc/ntp.conf /etc/ntp.conf.orig						# Preserves the origanal .conf file by renaming it
	touch /etc/ntp.conf										# Creates a blank .conf file to be used for the NTP client

	# Begin write to new ntp.conf
	echo "driftfile /var/lib/ntp/ntp.drift" >> /etc/ntp.conf
	echo "statistics loopstats peerstats clockstats" >> /etc/ntp.conf
	echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf
	echo "filegen peerstats file peerstats type day enable" >> /etc/ntp.conf
	echo "filegen clockstats file clockstats type day enable" >> /etc/ntp.conf

	echo "# LAN NTP source" >> /etc/ntp.conf
	echo " server $DNS1 iburst prefer" >> /etc/ntp.conf

	echo " By default, exchange time with everyone, but don't allow configuration" >> /etc/ntp.connf
	echo "restrict -4 default kod notrap nomodify nopeer noquery" >> /etc/ntp.connf
	echo "restrict 127.0.0.1" >> /etc/ntp.connf
}

