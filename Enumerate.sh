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
    echo -e -n "${GREEN}None found"
  else
    echo -e -n "${RED} $sudoMembers"
  fi
  echo -e "${RESET}"
  
}

enumFiles(){

  echo "*********************************************"
  echo "** Display all files with SUID permissions **"
  echo "*********************************************"
  echo -e -n "${RED}"
  find / -perm -4000 -exec ls -ldb {} \;
  echo -e "${RESET}"

  echo "*********************************************"
  echo "** Display all files with SGID permissions **"
  echo "*********************************************"
  echo -e -n "${RED}"
  find / -perm -2000 -exec ls -ldb {} \;
  echo -e "${RESET}"

  echo "*************************************************"
  echo "** Display all files with SUID/SGID permissions**"
  echo "*************************************************"
  echo -e -n "${RED}"
  find / -perm -6000 -exec ls -ldb {} \;
  echo -e "${RESET}"

  echo "**********************************"
  echo "** Display world-writable files **"
  echo "**********************************"
  echo -e -n "${RED}"
  find -xdev -type f -perm -o+w -name "*"  
  echo -e "${RESET}"

  echo "****************************************"
  echo "** Display world-writable directories **"
  echo "****************************************"
  echo -e -n "${RED}"
  find -xdev -type d -perm -o+w -name "*"  
  echo -e "${RESET}"


}


enumUsers
enumFiles


# Accidently deleted previous file and had to rebuild based of script output
# Will add flags in next version ~DW
