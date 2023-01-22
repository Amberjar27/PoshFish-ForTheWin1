#! /bin/bash
################################################################################
# Written by: nokonek                                                          #
# For: Metro State CCDC 2023                                                   #
# Purpose: To set the MOTD and enforce acceptance of message on SSH login      #
################################################################################

# Should allow for uninterupted insallation of SSH
sudo apt-get install ssh -y --allow-unauthenticated

# Make a back-up of the sshd_config file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

# Create banner text
echo "************************* WARNING! *************************" >> /etc/ssh/metro_banner
echo "*  This computer system is intended for * authorized users *" >> /etc/ssh/metro_banner
echo "*  only. You should have no expectation of privacy in your *" >> /etc/ssh/metro_banner
echo "*     use of this system. Use of this system constitutes   *" >> /etc/ssh/metro_banner
echo "*    consent to monitoring, retrieval, and disclosure of   *" >> /etc/ssh/metro_banner
echo "*  any activity. Any unauthorized activity will be subject *" >> /etc/ssh/metro_banner
echo "*        to requests to stop, pretty pretty please.        *" >> /etc/ssh/metro_banner
echo "************************************************************" >> /etc/ssh/metro_banner

# edit config
sudo sed -i 's,#Banner none,Banner /etc/ssh/metro_banner,' /etc/ssh/sshd_config

# Reload and restart SSH service
sudo systemctl reload ssh.service