#!/bin/bash
echo "Splunk IP is $1"
echo "Writing edits to /etc/rsyslog.conf"
echo "*.* @@$1:601" >> /etc/rsyslog.conf
echo "*.* @@$1:9997" >> /etc/rsyslog.conf
echo "Confirming edits"
tail -c 50 /etc/rsyslog.conf
echo "Fixing SELinux"
semanage port -a -t syslogd_port_t -p tcp 9997
semanage port -a -t syslogd_port_t -p tcp 601
echo "Restarting syslog service"
systemctl restart rsyslog || service rsyslog restart
echo "Sending test message"
hostname=$(hostname)
logger 'test message from $hostname'
echo "Syslog forwarding is set up... Probably..."
