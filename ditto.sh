################################################################################
# Written by: Radical Edward				 		       #
# For: Metro State CCDC 2023						       #
# Purpose: To change the alias' of nc & netcat to 'curl parrot.live'           #
################################################################################

#!/bin/bash

#NOTE: Run the script with the following command to apply the changes automatically: 'source ./setup_alias.sh'

# Step 1: Open the /etc/bash.bashrc file
sudo nano /etc/bash.bashrc

# Step 2: Add aliases for nc and netcat
echo "alias nc='/usr/bin/curl parrot.live'" | sudo tee -a /etc/bash.bashrc
echo "alias netcat='/usr/bin/curl parrot.live'" | sudo tee -a /etc/bash.bashrc

# Step 3: Save changes and exit
echo "Changes saved. Exiting nano..."

# Step 4: Apply changes
source /etc/bash.bashrc

echo "Alias setup complete."
echo "Run the command: 'sourcing /etc/bash.bashrc' to apply changes."
