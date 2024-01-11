#Initial Setup script for Splunk on CentOS6 written by Karl Boeh
#Needs some minor changes as of 1-10-2024

#!/bin/bash
echo "Setting stuff up"
echo "Grabbing scripts"

#Grab Porygon script
curl https://raw.githubusercontent.com/K7-Avenger/PoshFish-ForTheWin/main/porygon.sh > porygon.sh
chmod 755 porygon.sh

./porygon.sh r
cd ~
yum update -y


#Deploying Firewall
./porygon.sh f 2>/dev/null

echo "Time to change the root password"
passwd root

echo "Now for packages"
yum install -y -q epel-release
yum install -y -q clamav
yum install -y firefox
yum install -y tcpdump

yum list installed | grep -E 'epel-release|clamav|firefox|tcpdump' 2>/dev/null

#Edit rsyslog to allow incoming traffic on ports TCP 1601/UDP 1514
#UDP
sed -i 's/^#$ModLoad imudp/$ModLoad imudp/' /etc/rsyslog.conf
sed -i 's/^#$UDPServerRun 514/$UDPServerRun 514/' /etc/rsyslog.conf
#TCP
sed -i 's/^#$ModLoad imtcp/$ModLoad imtcp/' /etc/rsyslog.conf
sed -i 's/^#$InputTCPServerRun 514/$InputTCPServerRun 601/' /etc/rsyslog.conf
#Append this to the bottom of rsyslog.conf
echo "\$template RemoteLogs, \"var/log/%HOSTNAME%/%PROGRAMNAME%.log\"" >> /etc/rsyslog.conf
echo "*.* ?RemoteLogs" >> /etc/rsyslog.conf
echo "& ~" >> /etc/rsyslog.conf


echo "Now for Gnome!"
yum groupinstall -y 'X Window System'
yum groupinstall -y 'Desktop'
sed -i 's/^id:3:/id:5:/' /etc/inittab
yum groupinstall -y fonts

#compressed files show up as red which stand out
#think about ways to fix this and rename the backups to something less noticeable
cd /sbin
tar -czf etc_backup_rename.tar.gz /etc
tar -czf var_backup_rename.tar.gz /var/log
tar -czf bin_backup_rename.tar.gz /bin
cp porygon.sh /opt
cp porygon.sh /sbin
cp porygon.sh /etc

read -p "Press Enter to reboot into GUI..."
reboot -f
