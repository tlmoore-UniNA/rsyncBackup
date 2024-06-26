#!/usr/bin/env bash
# A script for backing up the /home directory via 'rsync'
#
# Requires the 'rsync' and 'udisks' utilities
# MOUNT ENCRYPTED DRIVE TO BACKUP LOCATION ===================================
sudo cryptsetup open /dev/sda1 vaultBackup # open the vault
udisksctl mount -b /dev/mapper/vaultBackup
# Device mounts to /run/media/tmoore/myvault

# BACKUP =====================================================================
# Set the source and target directories
#readonly SOURCE_DIR="${HOME}"
readonly SOURCE_DIR="${HOME}"
readonly BACKUP_DIR="/run/media/tmoore/myvault" # This is a your intended backup location.
# This directory is a persistent mount to an external hard disk (HD). See the  
# README for more information on how to configure the external HD.

## Get the system date and time
readonly DATETIME="$(date '+%Y-%m-%d_%H%M%S')"

# Setup a path new a new folder based on today's date
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

# Generate the "new" backup directory
mkdir -p "${BACKUP_DIR}"

# Run 'rsync' to backup the source to the the target
rsync -av --delete \
	   "${SOURCE_DIR}/" \
   --link-dest "${LATEST_LINK}" \
   --exclude=".cache" \
   "${BACKUP_PATH}"

# Remove the ${LATEST_LINK} and create a new link to the most recent backup
rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
# RUN THE PYTHON SCRIPT TO CLEANUP ===========================================
#nix-shell
#python3 ./cleanup.py
#exit
# UNMOUNT THE ENCRYPTED BACKUP DRIVE =========================================
udisksctl unmount -b /dev/mapper/vaultBackup
sudo cryptsetup close vaultBackup
