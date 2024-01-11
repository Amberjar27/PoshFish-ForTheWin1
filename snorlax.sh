#!/bin/bash
echo "Setting stuff up"
echo "Grabbing scripts"

#Hopefully, a team member can pull this script down immediately and you can pull it over with SCP in the first minutes.
#Otherwise, you will need to manually change the repos and run yum update -y before pulling this script over with
#curl. There is an SSL error for pulling from github on the version of curl that comes on CentOS6.4.

#combine these two into porygon.sh and pull from PoshFish repo
curl "https://raw.githubusercontent.com/boehkarl/CentOS6/main/repos.sh" >> repos.sh
curl "https://raw.githubusercontent.com/boehkarl/CentOS6/main/firewall.sh" >> firewall.sh
chmod 755 repos.sh firewall.sh

./repos.sh
yum update -y


#Deploying Firewall
./firewall.sh -s 2>/dev/null
service iptables save

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

read -p "Press Enter to reboot into GUI..."
reboot -f
