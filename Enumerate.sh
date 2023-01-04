#!/bin/bash

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

  echo "*********************************************"
  echo "** Files with SUID permissions **"
  echo "*********************************************"
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

# Commented out this check as it may not be very usefull
#  echo "********************************"
#  echo "** World-writable directories **"
#  echo "********************************"
#  worldWritableDirs=$(find / -type d -perm -o+w -name "*")
#  if(test -z "$worldWritableDirs"); then
#    echo -e -n "${GREEN}None found\n"
#  else
#    echo -e -n "${RED}$worldWritableDirs"
#  fi
#  echo -e "${RESET}"


}



enumUsers
enumFiles


# Accidently deleted previous file and had to rebuild based of script output
# Will add flags in next version ~DW
