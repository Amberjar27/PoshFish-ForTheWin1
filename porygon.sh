#Repo and firewall script for Splunk on CentOS6 written by Karl Boeh
#Firewall rules mostly stolen from Liam Powell

#bin/bash
firewall(){
  iptables -F
  
  #Policy rules
  iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT DROP

  #loopback
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT

  #DNS
  iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT 
  
  #Web traffic
  iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

  # Splunk WebGUI rules 
  iptables -A INPUT -p tcp --dport 8000 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 8000 -m state --state ESTABLISHED -j ACCEPT

  # Splunk Management Port
  iptables -A INPUT -p tcp --dport 8089 -m state --state NEW,ESTABLISHED -j ACCEPT

  # Syslog traffic
  iptables -A INPUT -p tcp --dport 9998 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport 1516 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp --dport 1515 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p udp --dport 1514 -m state --state NEW,ESTABLISHED -j ACCEPT

  service iptables save
}

firewall7(){

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
  f) firewall;;
  s) firewall7;;
  r) repos;;
esac
