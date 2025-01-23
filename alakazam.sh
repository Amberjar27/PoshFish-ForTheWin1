#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

echo "Starting full system backup..."

# Progress bar function
function progress_bar() {
  local progress=$1
  local total=$2
  local percentage=$(( progress * 100 / total ))
  local filled=$(( percentage / 2 ))
  local empty=$(( 50 - filled ))
  printf "\rProgress: [%-${filled}s>%${empty}s] %d%%" "=" "" "$percentage"
}

# Initialize variables
DIRECTORIES=(
  "/etc"
  "/var/www"
  "/var/mail"
  "/var/spool/postfix"
  "/var/lib/mysql"
  "/var/log"
  "/home"
  "/etc/ssl"
  "/root"
  "/boot"
  "/opt"
  "/usr/local/bin"
  "/usr/local/sbin"
  "/srv"
  "/etc/ssh"
  "/etc/postfix"
  "/etc/dovecot"
  "/etc/httpd"
  "/etc/php.ini"
  "/etc/roundcubemail"
)

TOTAL_STEPS=${#DIRECTORIES[@]}
CURRENT_STEP=0

# Increment and display progress
increment_progress() {
  ((CURRENT_STEP++))
  progress_bar $CURRENT_STEP $TOTAL_STEPS
}

# Step 1: Create a backup directory
BACKUP_DIR="/backup_full_$(date +%F)"
echo "Creating backup directory: $BACKUP_DIR"
mkdir -p $BACKUP_DIR
increment_progress

# Step 2: Backup each directory
for DIR in "${DIRECTORIES[@]}"; do
  BASENAME=$(basename $DIR)
  BACKUP_FILE="$BACKUP_DIR/${BASENAME}_backup.tar.gz"
  echo "Backing up $DIR to $BACKUP_FILE..."
  if [[ -d $DIR || -f $DIR ]]; then
    tar -czf $BACKUP_FILE $DIR &> /var/log/backup_${BASENAME}.log
  else
    echo "Warning: $DIR does not exist, skipping."
  fi
  increment_progress
done

# Step 3: Verify backup integrity
echo "Verifying backup integrity..."
if ls $BACKUP_DIR/*.tar.gz &> /dev/null; then
  echo "Backup completed successfully."
else
  echo "Backup failed. Check logs for details."
  exit 1
fi
increment_progress

# Step 4: Move backups to a hidden location
read -p "Enter the hidden backup directory location (default: /root/.hidden_backups): " HIDDEN_BACKUP_DIR
HIDDEN_BACKUP_DIR=${HIDDEN_BACKUP_DIR:-/root/.hidden_backups}
echo "Moving backups to hidden location: $HIDDEN_BACKUP_DIR"
mkdir -p $HIDDEN_BACKUP_DIR
for FILE in $BACKUP_DIR/*.tar.gz; do
  mv $FILE "$HIDDEN_BACKUP_DIR/$(basename $FILE)"
done
increment_progress

# Step 5: Set immutable attribute on backup files
echo "Setting immutable attribute on hidden backup files..."
for FILE in $HIDDEN_BACKUP_DIR/*; do
  chattr +i "$FILE"
done
increment_progress

# Completion message
progress_bar $TOTAL_STEPS $TOTAL_STEPS
echo

END_TIME=$(date)
echo "Full system backup completed at: $END_TIME"
echo "Backups have been moved to the selected hidden location and set to immutable."
