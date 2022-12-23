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
  for i in $(cut -d":" -f1 /etc/passwd);
    do id $i;
  done | grep "(root)"
  grep -v -E "^#" /etc/passwd | awk -F: '$3 == 0 { print $1}'
  echo -e "${RESET}"
  
  echo "**************************************"
  echo "**  Users with defined sudo rights  **"
  echo "**************************************"
  echo -e -n "${GREEN}"
  for j in $(cut -d":" -f1 /etc/passwd);
    do cat /etc/sudoers | grep "$j" | grep -wv Defaults | grep -wv "#";
  done
  echo -e "${RESET}"
  
  echo "**************************************"
  echo "**  Groups with defined sudo rights **"
  echo "**************************************"
  echo -e -n "${GREEN}"
  for k in $(cut -d":" -f1 /etc/group);
    do cat /etc/sudoers | grep "%$k" | grep -wv "#"
  done
  echo -e "${RESET}"
  
  echo "****************************************"
  echo "**  Non-root users in the sudo group  **"
  echo "****************************************"
  echo -e -n "${GREEN}"
  grep '^sudo:.*$' /etc/group | cut -d: -f4
  echo -e "${RESET}"
  
}

enumUsers

# Accidently deleted previous file and had to rebuild based of script output
# Will add flags in next version ~DW
