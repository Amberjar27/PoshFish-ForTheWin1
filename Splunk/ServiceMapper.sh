# Service Array

# Get running services && run each element
GetServices(){
	# Set boundary to newline
	IFS=$'\n'
	# Create regex to identify valid pids
	re='^[0-9]+$'
	# For loop to iterate running services
	for i in $(systemctl --type=service | grep running | awk '{print $1}'); do
		# Set IFS to . to split the service name. E.g., sshd.service -> sshd
		IFS='.';read -ra srr <<< "$i";
		# Get the pid of the service | str match might not be the most accurate ??
		pid=$(pidof ${srr[0]})
		# Process if a pid is found
		if [ "$pid" ] ; then
			# Set iterator to 0 to skip the garbage output of the next for loop
			a=0
			# Reset IFS back to newline
			IFS=$'\n'
			# Print service name
			printf "Name: ${srr[0]}\n"
			# Print associated pids
			printf "Processes: $pid\n"
			# Loop  through each process id
			for i in $(ps --pid $pid -o user,group,ppid,tty,etime,pid); do
				# Store current proc info into array
				IFS=' ';read -ra irr <<< "$i";
				# Test if pid is valid | garbage output stuff
				if [[ ${irr[5]} =~ $re ]]; then
					# Get the command that launched the process
					IFS=$'\n'; cmdr=($(ps --pid ${irr[5]} -o command))
					# Get the start time of the process
					time=$(ps -eo pid,lstart | awk -v id=${irr[5]} '$1 == id {print $2, $3, $4, $5, $6}')
					# Make array of net info for associated processes
					IFS=$'\n';net=$(netstat -tulnpa | awk '{print $1,$4,$5,$6,$7}' | grep -E '(^|[^0-9])'${irr[5]}'([^0-9])')
					# For every element in array
					for i in "${net[@]}"; do
						# make a new array split by spaces
						IFS=' ';read -ra nrr <<< "$i";
						# store info
						proto="${nrr[0]}"
						laddr="${nrr[1]}"
						raddr="${nrr[2]}"
						state="${nrr[3]}"
					done
				else
					# Command not found
					cmdr="NOT FOUND"
				fi
				# Process desired output
				if [ "$a" -gt 0 ]; then
					# Print terminal if in use
					if [ "${irr[3]}" != "?" ]; then
						printf "TTY: ${irr[3]}\n"
					fi
					# Print the stuff
					printf "\tPID: ${irr[5]}\n"
					printf "\tPPID: ${irr[2]}\n"
					printf "\tUser: ${irr[0]}\n"
					printf "\tGroup: ${irr[1]}\n"
					# Print all but the first array index
					printf "\tCommand: ${cmdr[@]:1}\n"
					printf "\tStart: $time\n"
					printf "\tRuntime: ${irr[4]}\n\n"
					if [[ $net ]]; then	
						printf "\tConnections\n"
						printf "\t\tProtocol: $proto\n"
						printf "\t\tLocal Address: $laddr\n"
						printf "\t\tRemote Address: $raddr\n"
						printf "\t\tState: $state\n\n"
					fi
				fi
				# iterate
				((a=a+1))
			done
			echo
		else
			# Only print if user wants 
			if [ "$DisplayNone" != "True" ]; then
				:
			else
				printf "Name: ${srr[0]}\n"
				printf "PID: NOT FOUND\n\n"
			fi
		fi
	done
}
# If no arguments, run GetServices
if [[ $OPTIND == 1 ]]; then
	GetServices
fi
# Getopts | with : in front, ignore getopts errors
while getopts ':hd:' opt; do
	case "$opt" i
n		h)
			printf "%s-d, DisplayNone\nDisplays services without processes when set to 'True'\n"
			exit
			;;
		d)
			if [ "$OPTARG" = "True" ]; then
				DisplayNone="True"
			else
				DisplayNone="False"
			fi
			GetServices	
			;;
		:)
			printf "Missing argument for $opt\nSee %s-h for help\n"
			;;
		# Unknown arg 
		\?)
			printf "See %s-h for usage information\n"
			;;
	esac
done	
