#!/bin/bash

################################################################################
# Written by: IV6IX						       #
# For: Metro State CCDC 2025                                                   #
# Purpose: To create a warning banner upon login for Debian 10 OS              #
################################################################################

# This section is used to define colors used to improve readability of output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Define the banner message
BANNER="
###############################################################################
#                                                                             #
#     Be advised all systems within this network are actively monitored,      #
#     and all activity is logged. Network usage is restricted to authorized   #
#     personnel only. Unauthorized usage will be investigated and may result  #
#     in civil and/or criminal penalties. By accessing this system, you       #
#     agree to be monitored and to not act maliciously. Tampering with any    #
#     of our systems will result in legal action.                             #
#                                                                             #
###############################################################################
"

# Update /etc/issue
echo "$BANNER" | sudo tee /etc/issue > /dev/null

# Update /etc/motd
echo "$BANNER" | sudo tee /etc/motd > /dev/null

# Update /etc/ssh/sshd_config to display the banner on SSH logins
SSH_BANNER_FILE="/etc/ssh/banner"
echo "$BANNER" | sudo tee $SSH_BANNER_FILE > /dev/null

# Modify sshd_config if not already set
if ! grep -q "^Banner $SSH_BANNER_FILE" /etc/ssh/sshd_config; then
    echo "Banner $SSH_BANNER_FILE" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi

# Restart SSH service to apply changes
sudo systemctl restart sshd

echo "Welcome banner has been updated successfully."
