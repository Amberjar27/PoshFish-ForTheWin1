#!/bin/bash
################################################################################
# Written by: K7-Avenger				 		       #
# For: Metro State CCDC 2023						       #
# Purpose: To investigate Linux hosts for potential weaknesses & IoC's, giving #
# users a better understanding of the host landscape, and prioritized list of  #
# manual enumeration items.						       #
################################################################################

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function definitions
enumUsers(){
  echo -e "${RESET}"
  echo "********************************"
  echo "**  Users who have logged in  **"
  echo "********************************"
  echo -e -n "${GREEN}"
  lastlog | grep -wv Never
  echo -e "${RESET}"

  echo "****************************************"
  echo "**  Users who are currently logged in **"
  echo "****************************************"
  echo -e -n "${GREEN}"
  w
  echo -e "${RESET}"
  
  echo "****************************************"
  echo "**  root user(s) & root group members **"
  echo "****************************************"
  echo -e -n "${GREEN}"
  for i in $(cut -d ":" -f1 /etc/passwd);
    do id $i;
  done | grep "(root)"
  grep -v -E "^#" /etc/passwd | awk -F: '$3 == 0 {print $1}'
  echo -e "${RESET}"
  
  echo "**************************************"
  echo "**  Users with defined sudo rights  **"
  echo "**************************************"
  echo -e -n "${GREEN}"
  for j in $(cut -d ":" -f1 /etc/passwd);
    do cat /etc/sudoers | grep "$j" | grep -wv Defaults | grep -wv "#";
  done
  echo -e "${RESET}"
  
  echo "**************************************"
  echo "**  Groups with defined sudo rights **"
  echo "**************************************"
  echo -e -n "${GREEN}"
  for k in $(cut -d ":" -f1 /etc/group);
    do cat /etc/sudoers | grep "%$k" | grep -wv "#"
  done
  echo -e "${RESET}"
  
  echo "****************************************"
  echo "**  Non-root users in the sudo group  **"
  echo "****************************************"
  sudoMembers=$(grep '^sudo:.*$' /etc/group | cut -d ":" -f4)
  if(test -z "$sudoMembers"); then
    echo -e -n "${GREEN}None found\n"
  else
    echo -e -n "${RED} $sudoMembers"
  fi
  echo -e "${RESET}"
  
}

enumFiles(){

  echo "*********************************"
  echo "** Files with SUID permissions **"
  echo "*********************************"
  sUidFiles=$(find / -type f -perm -4000  2> /dev/null)
  if(test -z "$sUidFiles"); then
    echo -e -n "${GREEN}None found\n"
  else
    echo -e -n "${RED}$sUidFiles\n"
  fi
  echo -e "${RESET}"

  echo "*********************************"
  echo "** Files with SGID permissions **"
  echo "*********************************"
  sGidFiles=$(find / -type f -perm -2000  2> /dev/null)
  if(test -z "$sGidFiles"); then
    echo -e -n "${GREEN}None found\n"
  else
    echo -e -n "${RED}$sGidFiles\n"
  fi
  echo -e "${RESET}"

  echo "***************************************"
  echo "** Files with SUID & SGID permissions**"
  echo "***************************************"
  sUGidFiles=$(find / -type f -perm -6000 2> /dev/null)
  if(test -z "$sUGidFiles"); then
    echo -e -n "${GREEN}None found\n"
  else
    echo -e -n "${RED}$sUGidFiles\n"
  fi
  echo -e "${RESET}"

  echo "*************************************"
  echo "** World-writable executable files **"
  echo "*************************************"
  worldWritableFiles=$(find / -type f -perm -o+wx 2> /dev/null)
  if(test -z "$worldWritableFiles"); then
    echo -e -n "${GREEN}None found\n"
  else
    echo -e -n "${RED}$worldWritableFiles\n"
  fi
  echo -e "${RESET}"

}

enumKeys(){
  echo "***********************************"
  echo "** Hidden keys and access tokens **"
  echo "***********************************"
  cryptoKey=$(find / -exec grep -rl -e "-----BEGIN PRIVATE KEY-----" {} \; 2> /dev/null)
  rsaPK=$(find / -exec grep -rl -e "-----BEGIN RSA PRIVATE KEY-----" {} \; 2> /dev/null)
  openSshPK=$(find / -exec grep -rl -e "-----BEGIN OPENSSH PRIVATE KEY-----" {} \; 2> /dev/null)
  pgpPK=$(find / -exec grep -rl -e "-----BEGIN PGP PRIVATE KEY BLOCK-----" {} \; 2> /dev/null)
  sshdsaPK=$(find / -exec grep -rl -e "-----BEGIN DSA PRIVATE KEY-----" {} \; 2> /dev/null)
  sshecPK=$(find / -exec grep -rl -e "-----BEGIN EC PRIVATE KEY-----" {} \; 2> /dev/null)

  keyCheck="$cryptoKey\n$rsaPK\n$openSshPK\n$pgpPK\n$sshdsaPK\n$sshecPK"
  keyCheck=$(echo -e -n "$keyCheck" | sort -u)

  if(test -z "$keyCheck"); then
    echo -e -n "${GREEN}No private keys not found\n"
  else
    echo -e -n "${RED}** Regex match(s), possible keys found: **\n${YELLOW}$keyCheck\n"
  fi
  echo -e "${RESET}"

}

enumLogs(){
  echo "*****************************"
  echo "** Suspicious log activity **"
  echo "*****************************"
}

enumConfigs(){
  echo "***************************"
  echo "** System Configurations **"
  echo "***************************"
  safeUmask=0137
  umaskValue=$(umask)
  umaskSymbolic=$(umask -S)

  if(("$umaskValue" >= "$safeUmask")); then
    echo -e -n "${GREEN}umask value of $umaskValue ($umaskSymbolic) appears safe\n"
  else
    echo -e -n "${RED}umask value of $umaskValue ($umaskSymbolic) is less than $safeUmask and appears unsafe\n"
  fi
  echo -e "${RESET}"
}

enumCronServices(){
  echo "*************"
  echo "** Crontab **"
  echo "*************"
  echo -e -n "${GREEN}"
  cat /etc/crontab
  echo -e "${RESET}"

  echo "*************************"
  echo "** Configured Cronjobs **"
  echo "*************************"
  echo -e -n "${GREEN}"
  ls -la /etc/cron*
  echo -e "${RESET}"

  echo "********************"
  echo "** System crontab **"
  echo "********************"
  echo -e -n "${GREEN}"
  cat /etc/cron.d/*
  echo -e "${RESET}"

  echo "*************************"
  echo "** Users with cronjobs **"
  echo "*************************"
  echo -e -n "${GREEN}"
  cut -d ":" -f 1 /etc/passwd | xargs -n1 crontab -l -u
  echo -e "${RESET}"

  echo "***************************************"
  echo "** Deleted binarys currently running **"
  echo "***************************************"
  deletedBinarys=$(ls -la /proc/*/exe 2> /dev/null | grep deleted | cut -d " " -f20)

  if(test -z "$deletedBinarys"); then
    echo -e "${GREEN}No deleted binaries running found"
  else
    mkdir /tmp/recovered_bins/ 2> /dev/null
    for j in $deletedBinarys;
	do k=$(echo $j | cut -d "/" -f 3) 
	cp $j /tmp/recovered_bins/bin_$k.sh
        echo -e "${RED}$j sent to /tmp/recovered_bins/bin_$k.sh"
	chmod 444 /tmp/recovered_bins/bin_$k.sh
    done
  fi
  echo -e "${RESET}"
}


while getopts 'ufcksl :' OPTION; do
	case "$OPTION" in
		u)
			enumUsers
			;;
		f)
			enumFiles
			;;
		c)
			enumConfigs
			;;
		k)
			enumKeys
			;;
		s)
			enumCronServices
			;;
		l)
			enumLogs
			;;

		?)
			echo -e -n "${YELLOW}"
			echo -e "Correct usage:\t $(basename $0) -flag(s)"
			echo -e "-u\t Enumerates users & groups"
			echo -e "-f\t Enumerates for suspicous or potentially exploitable files"
			echo -e "-c\t Identifies system configs that may be unsafe"
			echo -e "-k\t Searches the filesystem for access (SSH) keys"
			echo -e "-s\t Enumerates cronjobs & running services"
			echo -e "-l\t Searches logfiles for suspicious activity"
			echo -e "${RESET}"
			exit 1
			;;
	esac
done

# enumLogs & enumConfigs still not finished ~DW
