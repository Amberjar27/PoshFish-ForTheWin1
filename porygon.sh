#Repo and firewall script for Splunk on CentOS6 written by Karl Boeh
#Firewall rules mostly stolen from Liam Powell

#bin/bash
six(){
  iptables -F
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT
  iptables -A INPUT -p udp --dport 123 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT 
  iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport 8000 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 8000 -m state --state ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport 8089 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport 9998 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport 1516 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp --dport 1515 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp --dport 1514 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j DROP
  iptables -A OUTPUT -p tcp --dport 22 -m state --state ESTABLISHED -j DROP
  iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT DROP
  service iptables save
}

seven(){
  # FirewallD setup script for Splunk and Gravwell
  # Uses Firewall-CMD commands
  
  printf "Getting current configuration"
  Default_Zone=$(firewall-cmd --get-default-zone)
  firewall-cmd --zone=$Default_Zone  --list-all
  
  if [[ "$Default_Zone" = "public" ]] ; then
  	printf "Default zone is already set to public"
  else
  	printf "Setting active zone to public"
  	# Get ethernet adapter
  	eth=$(ip -br l | awk '$1 !~ "lo|vir|wl" {print $1}')
  	firewall-cmd --zone=public --change-interface=$eth
  fi
  
  printf "\nResetting firewall to defaults\n"
  printf "Setting target to DROP"
  firewall-cmd --zone=public --set-target=DROP --permanent

  sudo firewall-cmd --zone=public --add-interface=lo
  
  firewall-cmd --zone=public --add-service=http
  firewall-cmd --zone=public --add-service=https
  firewall-cmd --zone=public --add-port=53/udp
  firewall-cmd --zone=public --add-port=123/udp
  
  printf "Splunk installed\nBuilding firewall rules\n"
  #  Serve Splunk GUI over 8000
  firewall-cmd --zone=public --add-port=8000/tcp
  # Splunk indexer
  firewall-cmd --zone=public --add-port=8089/tcp 
  firewall-cmd --zone=public --add-port=1514/udp
  firewall-cmd --zone=public --add-port=1515/udp
  firewall-cmd --zone=public --add-port=1516/tcp

  firewall-cmd --zone=public --remove-port=22/tcp

  printf "\nReview current rules\n"
  Ports=$(firewall-cmd --list-ports)
  Services=$(firewall-cmd --list-services)
  Zones=$(firewall-cmd --get-active-zones)
  printf "Active Zone: $Zones\nOpen Ports\n$Ports\nOpen Services\n$Services\n"
  printf "Make current ruleset permanent?[y/n]\n"
  read input
  if [[ "$input" = "y" ]] ; then
  	firewall-cmd --runtime-to-permanent
  	firewall-cmd --reload
  else
  	printf "Rules are applied, but not permanent\nUse:\n\tfirewall-cmd --runtime-to-permanent\nTo make rules permanent\n"
  fi
}

repos(){
  echo "[C6.10-base]" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "name=CentOS-6.10 – Base" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "baseurl=http://vault.epel.cloud/6.10/os/\$basearch/" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgcheck=1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "enabled = 1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "metadata_expire=never" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  
  echo "[C6.10-updates]" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "name=CentOS-6.10 – Updates" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "baseurl=http://vault.epel.cloud/6.10/updates/\$basearch/" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgcheck=1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "enabled = 1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "metadata_expire=never" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  
  echo "[C6.10-extras]" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "name=CentOS-6.10 – Extras" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "baseurl=http://vault.epel.cloud/6.10/extras/\$basearch/" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgcheck=1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "enabled = 1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "metadata_expire=never" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  
  echo "[C6.10-contrib]" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "name=CentOS-6.10 – Contrib" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "baseurl=http://vault.epel.cloud/6.10/contrib/\$basearch/" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgcheck=1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "enabled = 1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "metadata_expire=never" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  
  echo "[C6.10-centosplus]" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "name=CentOS-6.10 – CentOSPlus" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "baseurl=http://vault.epel.cloud/6.10/centosplus/\$basearch/" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgcheck=1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "enabled = 1" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  echo "metadata_expire=never" >> /etc/yum.repos.d/CentOS-Base.repo.bak
  
  cd /etc/yum.repos.d
  mv CentOS-Base.repo CentOS-Base.repo.back
  mv CentOS-Base.repo.bak CentOS-Base.repo
}
case $1 in
  x) six;;
  n) seven;;
  r) repos;;
esac
