#!/bin/bash

################################################################################
# Written by: K7-Avenger													   #
# For: Metro State CCDC 2023                                                   #
# Purpose: To backup business critical directories, and directories seen in	   #
# previously documented RedTeam activity									   #
################################################################################

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

mkdir /tmp/critical_backups

# Create backups
tar -cf /tmp/critical_backups/initial_backup.tar /etc/
tar rf /tmp/critical_backups/initial_backup.tar /bin/

# Confirm backups
echo -e -n "${GREEN}"
tar -tf /tmp/critical_backups/initial_backup.tar
echo -e -n "${CYAN}"
echo "For instructions on extracting contents, see notes by DW"
echo -e "${RESET}"
