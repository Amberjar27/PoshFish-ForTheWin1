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

# See if gravwell is installed
# > /dev/null 2>&1 redirects output to a null file
printf "\nChecking for Gravwell\n"
Check_Gravwell=$(yum list installed gravwell)
if test -z "$Check_Gravwell" ; then 
	printf "Gravwell not installed, run Gravwell installer\n"
else
	printf "Gravwell installed\nBuilding firewall rules...\n"
	# Serve Gravwell over HTTP and HTTPS
	firewall-cmd --zone=public --add-service=http
	firewall-cmd --zone=public --add-service=https
	# indexers
	firewall-cmd --zone=public --add-port=4023/tcp
	firewall-cmd --zone=public --add-port=9404/tcp
	firewall-cmd --zone=public --add-port=601/tcp
	firewall-cmd --zone=public --add-port=514/udp
fi

printf "\nChecking for Splunk\n"
Check_Splunk=$(yum list installed splunk)
if test -z "$Check_Splunk" ; then
	printf "Splunk not installed, run Splunk installer\n"
else
	printf "Splunk installed\nBuilding firewall rules\n"
	#  Serve Splunk GUI over 8000
	firewall-cmd --zone=public --add-port=8000/tcp
	# Splunk indexer
	firewall-cmd --zone=public --add-port=8089/tcp 
	firewall-cmd --zone=public --add-port=9997/tcp
	firewall-cmd --zone=public --add-port=9998/tcp
	# Some other splunk stuff
	firewall-cmd --zone=public --add-port=8191/tcp
fi

printf "\nCreating block rules for non-essential services and ports\n"
# remove ssh
# Not really necessary with the default drop policy
printf "Removing SSH rules\n"
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


