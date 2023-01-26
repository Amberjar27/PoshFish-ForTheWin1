#!/bin/bash
# Consider cut -d " " -fx 
# count by delim not col

re='^[0-9]+$'
a=0
IFS=$'\n'
for i in $(netstat -tulnpa | awk '{print $1,$4,$5,$6,$7}')
do
	if [ $a -gt 1 ] ; then
		IFS=' '; read -ra arr <<< "$i"; IFS='/'; read -ra arr <<< "${arr[4]}"; id="${arr[0]}"
		# 
		if [[ $id =~ $re ]] ; then
			IFS=$'\n'; cmdr=($(ps --pid $id -o command))
		else
			cmdr="NOT FOUND"
		fi
		time=$(ps -eo pid,lstart | awk -v id=$id '$1 == id {print $2,$3,$4,$5,$6}')
		id=$(ps aux |awk -v id=$id '$2 == id {print $11, $1, $2, $7, $9, $10}')
		IFS=' '; read -ra pid <<< "$id";
		IFS=' ';read -ra irr <<< "$i";
		printf "_____________________________\n"
		echo
		printf "User: ${pid[1]}\n"
		printf "TTY: ${pid[3]}\n"
		printf "Start Time: $time\n"
		printf "Protocol: ${irr[0]}\n"
		printf "Local Address: ${irr[1]}\n"
		printf "Remote Address: ${irr[2]}\n"
		if [ "${irr[3]}" = "LISTEN" ] || [ "${irr[3]}" = "ESTABLISHED" ] || [ "${irr[3]}" = "CLOSE_WAIT" ] || [ "${irr[3]}" = "TIME_WAIT" ] ; then
			printf "State: ${irr[3]}\n"
			printf "Process: ${irr[4]}\n"
			# 
			printf "Command: ${cmdr[@]:1}\n"
		else
			printf "State: NONE\n"
			printf "Process: ${irr[3]}\n"
			printf "Command: ${pid[0]}\n"
		fi
	fi
	((a=a+1))
done