#!/bin/bash
printf "Checking Configuration...\n"
ip a > /dev/null 2>&1
printf "\nPulling out adapter...\n"
IFS=":";ad=$(ip a | awk '$1 == "2:" {print $2}');read -ra irr <<< $ad; echo "${irr[0]}"
printf "\nAdapter: ${irr[0]}\n"
printf "\nOpening network configuration...\n"
cat /etc/sysconfig/network-scripts/ifcfg-${irr[0]} 2>&1 | tee netconf.txt
printf "\nChecking repositories...\n"
ls /etc/yum.repos.d/
printf "\nInstalling software...\n"
yum install -y -q epel-release clamav ntp openssl > /dev/null 
printf "\nPulling scripts...\n"
curl "https://raw.githubusercontent.com/Somekindofclown/fish/Splunk/ServiceMapper.sh" >> ServiceMapper.sh 
curl "https://raw.githubusercontent.com/Somekindofclown/fish/Splunk/ProcessMapper.sh" >> ProcessMapper.sh 
curl "https://raw.githubusercontent.com/Somekindofclown/fish/Splunk/splunk_firewall.sh" >> Firewall.sh 
curl "https://raw.githubusercontent.com/Somekindofclown/fish/detective-pikachu.sh" >> Enum.sh
printf "\nRunning scripts...\n"
chmod 755 ServiceMapper.sh ProcessMapper.sh Firewall.sh Enum.sh > /dev/null 2>&1
bash Enum.sh 2>&1 | tee enumout.txt 
bash Firewall.sh 2>&1 | tee firewallout.txt 
bash ServiceMapper.sh 2>&1 | tee services.txt 
bash ProcessMapper.sh 2>&1 | tee processes.txt 
tar -cf gravbackup.tar /opt/gravwell/www &
tar -cf splunkbackup.tar /opt/splunk &
printf "\nScript Copmlete\n"
printf "\nInstalling GUI files...\n"
printf "\nLogging to /tmp/yum-out\n"
printf "\nSetting up syslog server settings...\n"
echo "\$template RemoteLogs,\"/var/log/%HOSTNAME%/%PROGRAMNAME%.log\"" >> /etc/rsyslog.conf
echo "*.* ?RemoteLogs" >> /etc/rsyslog.conf
echo "& ~" >> /etc/rsyslog.conf
printf "\nLines pushed to /etc/rsyslog.conf\n"
tail -c 50 /etc/rsyslog.conf
yum -y groups install "GNOME Desktop" >/tmp/yum-out 2>&1 &
echo "exec gnome-session" >> ~/.xinitrc
printf "Done installing, run startx to start\n"
