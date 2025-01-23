#!/bin/bash
#            ,".
#            |--\
#            | .'\   |.
#            |'  _\  |' ,.
#            |,.._ \_| `.|    .-"|
#          .'      .--   `. ,'," '
#         '_..._   ..|`    \ '  /
#         `     `.       .  /  /
#          .     ``.     ,' `./
#          |      `|`.   `-._ `""".
#          '       |.'`.     '   '
#           \           \  .'     `__,..
#            `.                ,.-'    '
#        _..-' `.     _.'   "-.|      /
#    _.-'    |  ,`"'""   _       `.  .-..
#  ,"   |    | .       .'  `     | `.  /  _,..
# |     '    ' |      /     |    |   `.`'"   '                _,..__
#.'.     `.__..| |\  /      '    |     \    /             _,'\    _.'
#|,'     ,' _..|.-'".            |      \  .            .'.   \,-'
# \",  .'  ,`-.      `.          |       \ `".       _,'   \ .'
#  `""'    ` ._\      |   _,.'   '        \ /___,.--"`.    .'
#          .`         |,-"     .+       _  V    `.     \  /
#           `-._    _,' `"-...' ,\ ."    `.|      .     \'
#              ,`.            .'  /        `.     |    /
#            ,'   \"--.....-"'   .        .  \    |  ,'
#           .    ."\           _,|        |   .   |.'
#           |  ,'   `-.____..-"  |        '   |_..'
#           | |       /`._      _|         \  |
#          ,. .       \   `-.-'"  .         \ |
#        .' |,-`     _/       `'""-`.        `.
#       -'".'  \_,-""                |.     .. |
#         ''"'""                     ' |  ,'  \|
#                                   | .'..|    |
#Accredited for being the first pokemon promgrammed data into the game. Change root/users and passwords      


# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Starting user account and credential security..."

# Secure critical files
FILES=("/etc/passwd" "/etc/shadow" "/etc/group" "/etc/gshadow")

# Step 1: Set appropriate permissions
secure_file_permissions() {
    echo -e "\n[1] Securing critical system files..."
    for FILE in "${FILES[@]}"; do
        if [[ -e $FILE ]]; then
            chmod 644 $FILE   # Default permissions for most files
            [[ "$FILE" == "/etc/shadow" || "$FILE" == "/etc/gshadow" ]] && chmod 600 $FILE
            chown root:root $FILE
            echo "Secured permissions for $FILE: $(ls -l $FILE)"
        else
            echo "Error: $FILE does not exist."
        fi
    done
}

# Step 2: Lock unused system accounts
lock_unused_accounts() {
    echo -e "\n[2] Locking unused system accounts..."
    for USER in $(awk -F: '($7 != "/bin/bash" && $7 != "/bin/zsh" && $7 != "/bin/sh") {print $1}' /etc/passwd); do
        passwd -l $USER &>/dev/null
        echo "Locked account: $USER"
    done
}

# Step 3: Remove accounts with UID 0 except root
remove_non_root_uid0() {
    echo -e "\n[3] Checking for unauthorized UID 0 accounts..."
    for USER in $(awk -F: '($3 == 0 && $1 != "root") {print $1}' /etc/passwd); do
        echo "Warning: Unauthorized UID 0 account found: $USER"
        read -p "Do you want to remove this account? (y/n): " RESPONSE
        if [[ $RESPONSE == "y" ]]; then
            userdel -r $USER
            echo "Removed account: $USER"
        else
            echo "Skipped account: $USER"
        fi
    done
}

# Step 4: Enforce password policies and force password changes
enforce_password_policies() {
    echo -e "\n[4] Enforcing password policies..."
    # Set password aging policies
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs
    echo "Updated password aging policies in /etc/login.defs"

    # Prompt root user to enter a password for forced changes
    read -sp "Enter a secure password for all forced changes: " FORCED_PASSWORD
    echo

    # Force password change for users with empty or invalid passwords
    for USER in $(awk -F: '($2 == "" || $2 == "*" || $2 == "!" ) {print $1}' /etc/shadow); do
        echo "Forcing password reset for user: $USER"
        echo -e "$FORCED_PASSWORD\n$FORCED_PASSWORD" | passwd $USER
    done
}

# Step 5: Disable root login over SSH
secure_ssh_access() {
    echo -e "\n[5] Securing SSH access..."
    SSH_CONFIG="/etc/ssh/sshd_config"
    if [[ -e $SSH_CONFIG ]]; then
        sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
        sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
        echo "Disabled root login and password authentication in $SSH_CONFIG"
        systemctl restart sshd
        echo "Restarted SSH service."
    else
        echo "Error: SSH configuration file $SSH_CONFIG not found."
    fi
}

# Step 6: Check for duplicate UIDs and GIDs
check_duplicates() {
    echo -e "\n[6] Checking for duplicate UIDs and GIDs..."
    DUPLICATE_UIDS=$(awk -F: '{print $3}' /etc/passwd | sort | uniq -d)
    if [[ -n $DUPLICATE_UIDS ]]; then
        echo "Duplicate UIDs found: $DUPLICATE_UIDS"
    else
        echo "No duplicate UIDs found."
    fi

    DUPLICATE_GIDS=$(awk -F: '{print $3}' /etc/group | sort | uniq -d)
    if [[ -n $DUPLICATE_GIDS ]]; then
        echo "Duplicate GIDs found: $DUPLICATE_GIDS"
    else
        echo "No duplicate GIDs found."
    fi
}

# Step 7: List users with sudo permissions
check_sudo_permissions() {
    echo -e "\n[7] Checking users with sudo permissions..."
    SUDO_USERS=$(grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n')
    echo "Users with sudo permissions:"
    echo "$SUDO_USERS"
}

# Step 8: Change root password
change_root_password() {
    echo -e "\n[8] Changing root password..."

    # Change Linux root password
    echo "Changing Linux root password..."
    read -sp "Enter new root password: " ROOT_PASSWORD
    echo
    echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root
}

# Run all functions
secure_file_permissions
lock_unused_accounts
remove_non_root_uid0
enforce_password_policies
secure_ssh_access
check_duplicates
check_sudo_permissions
change_root_password

echo -e "\nSystem credentials and user account security completed."

