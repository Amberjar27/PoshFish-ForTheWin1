#!/bin/bash
#                                            /
#                         _,.------....___,.' ',.-.
#                      ,-'          _,.--"        |
#                    ,'         _.-'              .
#                   /   ,     ,'                   `
#                  .   /     /                     ``.
#                  |  |     .                       \.\
#        ____      |___._.  |       __               \ `.
#      .'    `---""       ``"-.--"'`  \               .  \
#     .  ,            __               `              |   .
#     `,'         ,-"'  .               \             |    L
#    ,'          '    _.'                -._          /    |
#   ,`-.    ,".   `--'                      >.      ,'     |
#  . .'\'   `-'       __    ,  ,-.         /  `.__.-      ,'
#  ||:, .           ,'  ;  /  / \ `        `.    .      .'/
#  j|:D  \          `--'  ' ,'_  . .         `.__, \   , /
# / L:_  |                 .  "' :_;                `.'.'
# .    ""'                  """""'                    V
#  `.                                 .    `.   _,..  `
#    `,_   .    .                _,-'/    .. `,'   __  `
#     ) \`._        ___....----"'  ,'   .'  \ |   '  \  .
#    /   `. "`-.--"'         _,' ,'     `---' |    `./  |
#   .   _  `""'--.._____..--"   ,             '         |
#   | ." `. `-.                /-.           /          ,
#   | `._.'    `,_            ;  /         ,'          .
#  .'          /| `-.        . ,'         ,           ,
#  '-.__ __ _,','    '`-..___;-...__   ,.'\ ____.___.'
#  `"^--'..'   '-`-^-'"--    `-^-'`.''"""""`.,^.`.--'  
##Accredited for being the first Pokemon in th Pokedex with the number 0001. The first in the lore of Pokemon.
## 15

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

echo "Starting setup (50 tasks)..."

# Progress bar function
function progress_bar() {
  local progress=$1
  local total=$2
  local percentage=$(( progress * 100 / total ))
  local filled=$(( percentage / 2 ))
  local empty=$(( 50 - filled ))
  printf "\rProgress: [%-${filled}s>%${empty}s] %d%%" "=" "" "$percentage"
}

# Initialize variables
TOTAL_TASKS=50
CURRENT_TASK=0

# Increment and display progress
increment_progress() {
  ((CURRENT_TASK++))
  progress_bar $CURRENT_TASK $TOTAL_TASKS
}

# Timestamp
START_TIME=$(date)
echo "Script started at: $START_TIME"
increment_progress

# 1. Update system packages
(
  echo "Updating system packages..."
  yum update && yum upgrade -y
) &> /var/log/.nccdc_update.log
increment_progress


# 2. Install essential services (LAMP stack and dependencies)
(
  echo "Installing LAMP stack and required services..."
  yum install -y httpd mariadb-server mariadb php php-mysqlnd postfix dovecot mod_ssl
) &> /var/log/nccdc_install.log
increment_progress

# 3. Start and enable services
for service in httpd mariadb postfix dovecot; do
    (
      echo "Enabling and starting $service..."
      systemctl enable $service
      systemctl start $service
    ) &>> /var/log/nccdc_services.log
  done
increment_progress

# 4. Secure MySQL installation
(
  echo "Securing MySQL installation..."
  mysql_secure_installation <<EOF
n
y
y
y
y
EOF
) &>> /var/log/nccdc_mysql_secure.log
increment_progress

# 10. Quick Logging Setup (Rsyslog)
echo '*.* @172.20.241.20:1514' | sudo tee -a /etc/rsyslog.conf > /dev/null && sudo systemctl restart rsyslog
(
  echo "Restarting Rsyslog..."
) &>> /var/log/nccdc_rsyslog.log
increment_progress

# 13. Disable Root SSH Login
sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
(
  echo "Restarting SSH..."
  systemctl restart sshd
) &>> /var/log/nccdc_ssh.log
increment_progress

# 14. Quick Fail2Ban Installation and Setup
yum install -y fail2ban
cat > /etc/fail2ban/jail.local <<EOL
[sshd]
enabled = true
bantime = 3600
findtime = 600
maxretry = 5
EOL
systemctl enable fail2ban
systemctl start fail2ban
increment_progress

# 15. Enable SELinux
echo "Enforcing SELinux..."
setenforce 1
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
increment_progress

# 16. Install and Configure AIDE
(
  echo "Installing and configuring AIDE..."
  yum install -y aide
  aide --init
  mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
) &>> /var/log/nccdc_aide.log
increment_progress

# 18. Configure Password Policies
(
  echo "Setting strong password policies..."
  authconfig --passminlen=12 --passminclass=3 --update
  echo "password requisite pam_pwquality.so retry=3" >> /etc/security/pwquality.conf
) &>> /var/log/nccdc_password_policies.log
increment_progress

# 19. Enable Automatic Updates
(
  echo "Enabling automatic updates..."
  yum install -y yum-cron
  systemctl enable yum-cron
  systemctl start yum-cron
) &>> /var/log/nccdc_updates.log
increment_progress

# 21. Implement Intrusion Detection (OSSEC)
(
  echo "Installing OSSEC HIDS..."
  yum install -y epel-release
  yum install -y ossec-hids ossec-hids-server
  systemctl enable ossec-hids
  systemctl start ossec-hids
) &>> /var/log/nccdc_ossec.log
increment_progress

# 24. Set Up Time Synchronization
(
  echo "Setting up Chrony for time synchronization..."
  yum install -y chrony
  systemctl enable chronyd
  systemctl start chronyd
) &>> /var/log/nccdc_chrony.log
increment_progress

# 26. Configure File Integrity Monitoring (Tripwire)
(
  echo "Installing and configuring Tripwire..."
  yum install -y tripwire
  tripwire --init
) &>> /var/log/nccdc_tripwire.log
increment_progress

# 28. Install and Configure RKHunter
(
  echo "Installing and configuring RKHunter..."
  yum install -y rkhunter
  rkhunter --update
  rkhunter --propupd
) &>> /var/log/nccdc_rkhunter.log
increment_progress

# 29. Restrict Access to Crontab
(
  echo "Restricting access to crontab..."
  chmod 600 /etc/crontab
  chmod 700 /etc/cron.*
) &>> /var/log/nccdc_crontab_restrict.log
increment_progress

# 30. Configure Network Time Protocol (NTP) Security
(
  echo "Securing NTP..."
  yum install -y ntp
  ntpd -qg
  systemctl enable ntpd
  systemctl start ntpd
) &>> /var/log/nccdc_ntp.log
increment_progress

# 34. Restrict SSH User Access
(
  echo "Restricting SSH access to specific users..."
  echo "AllowUsers adminuser" >> /etc/ssh/sshd_config
  systemctl restart sshd
) &>> /var/log/nccdc_ssh_users.log
increment_progress

# 35. Enable Audit Logging for Critical Files
(
  echo "Enabling audit logging for critical files..."
  auditctl -w /etc/passwd -p wa -k passwd_changes
  auditctl -w /etc/shadow -p wa -k shadow_changes
) &>> /var/log/nccdc_audit_logging.log
increment_progress

# 37. Disable Unnecessary Filesystems
(
  echo "Disabling unused filesystems..."
  echo "install cramfs /bin/true" >> /etc/modprobe.d/cramfs.conf
  echo "install freevxfs /bin/true" >> /etc/modprobe.d/freevxfs.conf
) &>> /var/log/nccdc_filesystems.log
increment_progress

# 45. Enable Log Rotation
(
  echo "Configuring logrotate for logs..."
  yum install -y logrotate
  logrotate /etc/logrotate.conf
) &>> /var/log/nccdc_logrotate.log
increment_progress

# Timestamp for script completion
END_TIME=$(date)
echo "Script completed at: $END_TIME"
echo "Review log files in /var/log for details."

# Final progress bar completion
progress_bar $TOTAL_TASKS $TOTAL_TASKS
echo

echo "0001 task setup completed successfully!"

