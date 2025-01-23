#! /bin/bash

show_menu() {
  echo "******************************"
  echo "             Menu             "
  echo "******************************"
  echo "1) Complete Centos7 EOL Repo"
  echo "2) Issue Password Update"
  echo "3) System Update"
  echo "4) Install ClamAV"
  echo "5) Install Fail2Ban and Create Jails"
  echo "6) Set Directory Permissions"
  echo "7) Apply Firewall Rules"
  echo "8) Backup Directories"
  echo "9) Create MOTD"
  echo "10) CoCap Stuff"
}

option1() {
  cento7_repo="/etc/yum.repos.d"

  echo "Backing up repo files..."
  mkdir -p /etc/yum.repos.d/repo_backups
  cp -r "$centos7_repo"/*.etc/yum.repos.d/repo_backups

  echo "disabling current repositories..."
  for repo in $(globs "$centos7_repo"/*.repo);
  do
    sed -i 's/enabled=1/enabled=0/'
  $repo
  done

  echo "Adding EOL Centos7 repo..."

  cat <<EOF > "$centos7_repo"/CentOS-Vault.repo
  [centos7-vault]
  name=CentOS-7 Vault Repository
  baseurl=http://vault.centos.org/7.9.2009/os/x86_64/
  enabled=1
  gpgcheck=1
  gpgkey=http://vault.centos.org/RPM-GPG-KEY-CentOS-7
EOF

  echo "EOL Centos7 repo added"
  yum clean all
  yum update -y
  echo "Centos7 EOL repositories completed"
}

option2() {
  oddish_check
  password users=$(cat /etc/shadow | grep -wv * | grep -wv ! | cut -d \: -f 1)
  for user in $password_users
    do
      read -p "Enter a new and unique password for $user: " newpass
      echo "$user:$newpass" | chapasswd
      echo "Password for $user updated."
    done
  }

option3() {
  echo "Updating System..."
  yum update && yum update epel-release
  yum clean all
  yum list updates
  yum update httpd mysql-server php
  echo "System Updated"
  }

option4() {
  echo "Installing ClamAV..."
  yum install clamav -y
  freshclam
  echo "Install Complete"
  }

option5() {
  echo "Installing Fail2Ban..."
  yum install fail2ban -y
  echo "Fail2Ban Installed, enabling services..."
  systemctl enable fail2ban 
  systemctl start fail2ban
  echo "Adding Jails..."
  }

  cat <<EOF > /etc/fail2ban/jail.local

  [apache]
  enabled = true
  port = http, https
  filter = apache-auth
  logpath = /var/log/httpd/*access_log
  maxretry = 3
  bantime = 600
  findtime = 600

  [shellshock-apache]
  enabled = true
  port = http, https
  filter = heartbleed
  logpath = /var/log/httpd/*access_log
  maxretry = 3

  [heartbleed-apache]
  enabled = true
  port = http, https
  filter = shellshock
  logpath = /var/log/httpd/*access_log
  maxretry = 3

  [mysql]
  enabled = true
  port = mysql
  filter = mysql-auth
  logpath = /var/log/mysqld.log
  maxretry = 3
  bantime = 600
  findtime = 600
EOF
##ADD FILTERS##
  systemctl restart fail2ban
  fail2ban-client status

  echo "Jails added successfully"


  option6() {
    echo "Applying permissions for directories..."
    chmod -R 755 /var/www/html/
    chmod -R 755 /var/www/html/uploads
    chown -R www-data:www-data /var/www/html/uploads
    chmod -R 755 /opt/prestashop
    chmod -R 755 /opt/prestashop/uploads
    chown apache:apache /opt/prestashop/uploads
    chmod 640 /opt/prestashop/config/settings.inc.php
    chown root:root /opt/prestashop/config/settings.inc.php
    }

  option7() {
    echo "Enabling iptables..."
    systemctl stop firewalld
    systemctl disable firewalld
    systemctl enable iptables
    systemctl start iptables
    systemctl status iptables
    echo "iptables enabled"
    echo "Setting up firewall rules..."
    iptables -F
    iptables -F INPUT
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    #HTTP
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
    #HTTPS
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
    #DNS
    iptables -A INPUT -p tcp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
    iptables -A INPUT -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    #NTP
    iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
    #CoCap
    iptables -A OUTPUT -p tcp --dport 1514 -d 172.20.241.20 -j ACCEPT
    iptables -A OUTPUT -p
    service iptables save
    iptables -L
    echo "Firewall rules enabled"
    }

  option8() {
    echo "Backing up directories..."
    cp -r /var/www/html /home/sysadmin/.backup
    cp -r /etc/httpd /home/sysadmin/.backup
    cp -r /var/lib/MySQL /home/sysadmin/.backup
    cp /etc/my.cnf /home/sysadmin/.backup
    cp -r /etc/my.cnf.d /home/sysadmin/.backup
    MySQLdump -u root -p --all-databases > /home/sysadmin/.backup/alldatabases.sql
    cp /etc/php.ini /home/sysadmin/.backup/php_configs
    cp -r /etc/php.d /home/sysadmin/.backup/php_modules
    cp -r /etc/ssl/certs /path/of/preference/ssl_certs
    cp -r /etc/ssl/private /home/sysadmin/.backup/ssl_pkey
    cp /etc/httpd/conf.d/ssl.conf /home/sysadmin/.backup/ssl_configs
    cp -r /var/log/httpd /home/sysadmin/.backup/httpd_logs
    cp /var/log/messages /home/sysadmin/.backup/sys_logs
    cp /var/log/secure /home/sysadmin/.backup/sys_logs
    cp /etc/crontab /home/sysadmin/.backup/crontab
    cp -r /etc/cron.d /home/sysadmin/.backup/cron_d
    echo "Backup complete"
  }

  option9() {
    echo "Applying MOTD warning..."
    MOTD="Be advised all systems within this network are actively monitored, and all
activity is logged. Network activity is subject to random audits at any time.
By entering our web space you agree not only to be monitored, but also to not 
act maliciously.
Unauthorized Users: This is your first and only opportunity to leave.
Enter at your own risk."
    echo -e "$MOTD" > /etc/motd
    echo "MOTD added sucessfully"
    }
  option10() {
    echo '*.* @172.20.241.20:1514' | tee -a /etc/rsyslog.conf > /dev/null
    systemctl restart rsyslog
    echo "CoCap Stuff Done!"
  }

while true; do
    show_menu
    read -r choice "Select Option: "
    case $choice in
        1)
            option1
            ;;
        2)
            option2
            ;;
        3)
            option3
            ;;
        4)
            option4
            ;;
        5)
            option5
            ;;
        6)
            option6
            ;;
        7)
            option7
            ;;
        8)
            option8
            ;;
        9)
            option9
            ;;
        10)
            option10
            ;;
        11)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
      esac
      echo ""
done
