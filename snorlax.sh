################################################################################
# Written by: Karl Boeh                                     				 		       #
# For: Metro State CCDC 2024                                						        #
# Purpose: Performs the initial hardening/setup tasks for the Splunk           #
# machine. Running snorlax.sh with flag (x) will perform setup on CentOS6.     #
# Running snorlax.sh with flag (n) will perform setup on CentOS7               #
################################################################################

#!/bin/bash

six(){
echo "Setting stuff up"
echo "Grabbing scripts"

#Grab Porygon script
curl https://raw.githubusercontent.com/Amberjar27/PoshFish-ForTheWin1/main/porygon.sh > porygon.sh
chmod 755 porygon.sh

./porygon.sh r
cd ~
yum update -y

#Deploying Firewall
./porygon.sh x 2>/dev/null

echo "Time to change the root password"
passwd root

echo "Now for packages"
yum install -y -q epel-release
yum install -y -q clamav
yum install -y firefox
yum install -y tcpdump
yum install -y ntp

yum list installed | grep -E 'epel-release|clamav|firefox|tcpdump|ntp' 2>/dev/null

#Edit rsyslog to allow incoming traffic on ports TCP 1516/UDP 1515/Palo 1514/UDP
#UDP
sed -i 's/^#$ModLoad imudp/$ModLoad imudp/' /etc/rsyslog.conf
sed -i 's/^#$UDPServerRun 514/$UDPServerRun 1515/' /etc/rsyslog.conf
#TCP
sed -i 's/^#$ModLoad imtcp/$ModLoad imtcp/' /etc/rsyslog.conf
sed -i 's/^#$InputTCPServerRun 514/$InputTCPServerRun 1516/' /etc/rsyslog.conf
#Append this to the bottom of rsyslog.conf
echo "\$template RemoteLogs,\"var/log/%HOSTNAME%/%PROGRAMNAME%.log\"" >> /etc/rsyslog.conf
echo "*.* ?RemoteLogs" >> /etc/rsyslog.conf
echo "& ~" >> /etc/rsyslog.conf

echo "Now for Gnome!"
yum groupinstall -y 'X Window System'
yum groupinstall -y 'Desktop'
sed -i 's/^id:3:/id:5:/' /etc/inittab
yum groupinstall -y fonts

read -p "Press Enter to reboot into GUI..."
reboot -f
}

seven(){
  yum update -y

  curl https://raw.githubusercontent.com/Amberjar27/PoshFish-ForTheWin1/main/porygon.sh > porygon.sh
  chmod 755 porygon.sh

  #Deploying Firewall
  ./porygon.sh n
  
  echo "Time to change the root password"
  passwd root
  
  echo "Now for packages"
  yum install -y -q clamav
  yum install -y firefox
  yum install -y tcpdump
  yum install -y ntp
  yum install -y net-tools
  
  yum list installed | grep -E 'clamav|firefox|tcpdump|ntp|net-tools' 2>/dev/null

  #Edit rsyslog to allow incoming traffic on ports TCP 1516/UDP 1515/Palo 1514/UDP
  #UDP
  sed -i 's/^#$ModLoad imudp/$ModLoad imudp/' /etc/rsyslog.conf
  sed -i 's/^#$UDPServerRun 514/$UDPServerRun 1515/' /etc/rsyslog.conf
  #TCP
  sed -i 's/^#$ModLoad imtcp/$ModLoad imtcp/' /etc/rsyslog.conf
  sed -i 's/^#$InputTCPServerRun 514/$InputTCPServerRun 1516/' /etc/rsyslog.conf
  #Append this to the bottom of rsyslog.conf
  echo "\$template RemoteLogs,\"var/log/%HOSTNAME%/%PROGRAMNAME%.log\"" >> /etc/rsyslog.conf
  echo "*.* ?RemoteLogs" >> /etc/rsyslog.conf
  echo "& ~" >> /etc/rsyslog.conf

  yum -y groups install "GNOME Desktop"
  systemctl set-default graphical.target
  echo "exec gnome-session" >> ~/.xinitrc
  read -p "Press Enter to start GUI..."
  startx
}

case $1 in
  x) six;;
  n) seven;;
esac
