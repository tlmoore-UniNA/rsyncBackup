#!/bin/bash
# A script for backing up the /home directory via 'rsync'
#
# Requires the 'rsync' utility
# BACKUP =====================================================================
# Set the source and target directories
readonly SOURCE_DIR="${HOME}"
readonly BACKUP_DIR="/Backup" # '/Backup' is a your intended backup location.
# This directory is a persistent mount to an external hard disk (HD). See the 
# README for more information on how to configure the external HD.

# Get the system date and time
readonly DATETIME="$(date '+%Y-%m-%d_%H%M%S')"

# Setup a path new a new folder based on today's date
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

## Generate the "new" backup directory
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


# TRIM OLD BACKUPS ===========================================================
# Trim backups to keep 1 annual, 12 recent months, and 7 recent days
#
# Find all sub-directories with the format "%Y-%m-%d" in the name
# Find all sub-directories with the format "%Y-%m-%d" in the name
sub_dirs=$(find "$SEARCH_DIR" -type d -regex ".*/[0-9]{4}-[0-9]{2}-[0-9]{2}")

# Create arrays to hold directories by year, month, and day
declare -A year_dirs
declare -A month_dirs
declare -A day_dirs

# Loop through the sub-directories and categorize them
for dir in $sub_dirs; do
    # Extract year, month, and day from directory name
    year=$(basename "$dir" | cut -d'-' -f1)
    month=$(basename "$dir" | cut -d'-' -f2)
    day=$(basename "$dir" | cut -d'-' -f3)

    # Add directory to the respective arrays
    year_dirs["$year"]+="$dir "
    month_dirs["$year-$month"]+="$dir "
    day_dirs["$year-$month-$day"]+="$dir "
done

# Keep only 1 directory per year, 12 directories per year-month, and 7 directories per year-month-day
for year in "${!year_dirs[@]}"; do
    dirs_to_keep=$(echo "${year_dirs[$year]}" | head -n1)
    for month in "${!month_dirs[@]}"; do
        if [[ "$month" == "$year-"* ]]; then
            dirs_to_keep+="$(echo "${month_dirs[$month]}" | head -n12)"
        fi
    done
    for day in "${!day_dirs[@]}"; do
        if [[ "$day" == "$year-"* ]]; then
            dirs_to_keep+="$(echo "${day_dirs[$day]}" | head -n7)"
        fi
    done
done

# Delete directories that are not in the keep list
for dir in $sub_dirs; do
    if [[ ! " ${dirs_to_keep[@]} " =~ " ${dir} " ]]; then
        echo "Deleting $dir"
        # Uncomment the following line to delete the directories
        # rm -rf "$dir"
    fi
done
