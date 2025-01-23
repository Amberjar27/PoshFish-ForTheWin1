#! /bin/bash⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
############################################################################
#Script will do the following steps:
#Issue test message
#Issue Password Update
#Complete System Update
#Set Directory Permissions
#Apply iptables
#Backup Directories
#Create MOTD banner
#Log configuration
###########################################################################

show_menu() {
  echo "******************************"
  echo "             Menu             "
  echo "******************************"
  echo "1) Test"
  echo "2) Issue Password Update"
  echo "3) System Update"
  echo "4) Set Directory Permissions"
  echo "5) Apply Firewall Rules"
  echo "6) Backup Directories"
  echo "7) Create MOTD"
  echo "8) CoCap Stuff"
}

option1() {
  echo "Testing..."
}

option2() {
  password_users=$(cat /etc/shadow | grep -wv "\*" | grep -wv "!" | cut -d : -f 1)
  for user in $password_users
    do
      read -r "Enter a new and unique password for $user: " newpass
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
    echo "Applying permissions for directories..."
    chmod -R 755 /var/www/html/
    chown -R apache:apache /var/www/html/
    chmod -R 755 /var/www/html/prestashop/upload
    chown -R apache:apache /var/www/html/prestashop/upload
    chmod -R 755 /var/www/html/prestashop
    chmod 640 /var/www/html/prestashop/config/settings.inc.php
    chown root:root /var/www/html/prestashop/config/settings.inc.php
    echo "Permissions applied"
    }

  option5() {
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
    #Additional Rules
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -p
    service iptables save
    iptables -L
    echo "Firewall rules enabled"
    }

  option6() {
    echo "Backing up directories..."
    cp -r /var/www/html /home/sysadmin/.backup
    cp -r /etc/httpd /home/sysadmin/.backup
    cp -r /var/lib/mysql /home/sysadmin/.backup
    cp /etc/my.cnf /home/sysadmin/.backup
    cp -r /etc/my.cnf.d /home/sysadmin/.backup
    cp /etc/php.ini /home/sysadmin/.backup/php_configs
    cp -r /etc/php.d /home/sysadmin/.backup/php_modules
    cp /etc/httpd/conf.d/ssl.conf.rpmsave /home/sysadmin/.backup/ssl_configs
    cp -r /var/log/httpd /home/sysadmin/.backup/httpd_logs
    cp /var/log/messages /home/sysadmin/.backup/sys_logs
    cp /var/log/secure /home/sysadmin/.backup/sys_logs
    cp /etc/crontab /home/sysadmin/.backup/crontab
    cp -r /etc/cron.d /home/sysadmin/.backup/cron_d
    echo "Backup complete"
  }

  option7() {
    echo "Applying MOTD warning..."
    MOTD="***********************************WARNING!*************************
    This computer system is intended for authorized users only. Use of this 
    system constitutes consent to monitoring, retrieval, and disclosure of any 
    activity. Any unauthorized activity will be subject to request to stop.
    **********************************************************************"
    echo -e "$MOTD" > /etc/motd
    echo "MOTD added sucessfully"
    }
  option8() {
    echo '*.* @172.20.241.20:1514' | tee -a /etc/rsyslog.conf > /dev/null
    systemctl restart rsyslog
    echo "CoCap Stuff Done!"
  }

while true; do
    show_menu
    read -r choice
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
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
      esac
      echo ""
done
