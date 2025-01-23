#!/bin/bash
##################################################################
# CREATEd BY TIEN                            			 #        
# SETTING FIREWALL RULES and rules for splunker                   #           
#                                                                #  
# ./Blastoise.sh 15                                              #  
# ./Blastoise.sh fire 			                         # 
# ./Blastoise.sh fire 			                         #  
##################################################################



##############################################
#                                            #
#                   ip                       #
#				             #
##############################################	
window="172.20.242.200"
dns="172.20.240.20"
unbuntu="172.20.242.10"
splunk="172.20.241.20"
webmail="172.20.241.40"
ecomm="172.20.241.30"
palo="172.20.242.150"



##############################################
#                                            #
#                 firewall                   #
#					     #
##############################################

firewall(){

	# Remove all services, ports, and rich rules
	sudo firewall-cmd --permanent --remove-service=all
	sudo firewall-cmd --permanent --remove-port=all

	# Flush all rich rules
	sudo firewall-cmd --permanent --remove-rich-rule='rule'

	# Reset default zone configuration
	sudo firewall-cmd --permanent --set-default-zone=public

    echo "Logging for Linux machines..."
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.242.10" port port="1514" protocol="udp" log prefix="Ubuntu_1514 " level="info" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.240.20" port port="1514" protocol="udp" log prefix="DNS_1514 " level="info" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.241.40" port port="1514" protocol="udp" log prefix="Webmail_1514 " level="info" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.242.150" port port="1514" protocol="udp" log prefix="Palo_1514 " level="info" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.241.30" port port="1514" protocol="udp" log prefix="Ecomm_1514 " level="info" accept'

    echo "Logging for Windows machines..."
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.242.200" port port="9998" protocol="tcp" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.240.10" port port="9998" protocol="tcp" accept'

    echo "Allowing outbound traffic for HTTP/HTTPS..."
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination port port="80" protocol="tcp" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination port port="443" protocol="tcp" accept'

    echo "Restricting Splunk ports to trusted IPs..."
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.241.20" port port="8089" protocol="tcp" accept'
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.20.241.20" port port="8000" protocol="tcp" accept'

    echo "Removing unnecessary services..."
    sudo firewall-cmd --permanent --remove-service=ssh
    sudo firewall-cmd --permanent --remove-service=telnet
    sudo firewall-cmd --permanent --remove-service=ftp
    sudo firewall-cmd --permanent --remove-service=cockpit
    sudo firewall-cmd --permanent --remove-service=dhcpv6-client

    echo "Blocking unused remote access ports..."
    sudo firewall-cmd --permanent --add-rich-rule='rule port port="3389" protocol="tcp" reject'  # RDP
    sudo firewall-cmd --permanent --add-rich-rule='rule port port="5900" protocol="tcp" reject'  # VNC
    sudo firewall-cmd --permanent --add-rich-rule='rule port port="23" protocol="tcp" reject'    # Telnet
    sudo firewall-cmd --permanent --add-rich-rule='rule port port="21" protocol="tcp" reject'    # FTP Control
    sudo firewall-cmd --permanent --add-rich-rule='rule port port="20" protocol="tcp" reject'    # FTP Data

    echo "Setting global reject rule for untrusted traffic..."
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination address="0.0.0.0/0" reject'

    echo "Reloading firewalld and listing rules..."
    sudo firewall-cmd --reload
    sudo firewall-cmd --list-all
}




get_gui(){

 	yum groupinstall "xfce" -y
 	yum install firefox -y
 	systemctl set-default graphical.target
 	reboot

}

listen(){
	sudo semanage port -a -t syslogd_port_t -p udp 1514
	sudo semanage port -m -t syslogd_port_t -p udp 1514
}

##############################################
#                                            #
#                 first-15                   #
#					     #
##############################################

first15(){


	echo "running updates....."
	sudo update -y && sudo yum upgrade -y 
	firewall
	# install interprise 
	sudo yum install -y oracle-epel-release-el9



	#channging password
	sudo passwd root
	sudo passwd sysadmin
	sudo passwd splunk

	#editing sudoers file
	sudo nano /etc/sudoers 
	#disabling root login : adding sbin/nologin
	sudo nano /etc/passwd

  	sudo yum install chrony -y
	#ntp config 
	sudo nano /etc/chrony.conf
 	#dns config 
 	sudo nano /etc/resolv.conf
	get_gui 

}


case "$1" in
	15)
	first15
	;;
	fire)
	firewall
	;;
 	logger)
  	listen
   	;;
esac 
