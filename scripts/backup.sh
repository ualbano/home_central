#! /bin/bash
# This Script is used for backup my Home Central. The backup is only including
# files which are generated during the run time. Other files like the
# Configuration are saved in the git repo and don't need to be backed up.
# The Backup are stored to a location in the local file system, this location is
# backed up by another mechanic.
#
# This Script also delete older versions of the Backups.

set -eu

#NOTE: Change here to edit the backup target
TARGET_BACKUP_DIR="${BACKUP_DIR:-/mnt/external_disk/backups/homecentral}"
DAYS_TO_RETAIN="${DAYS_TO_RETAIN:-30}"
#HAS is storing all data to config/has, this location needs to be backed up, even if there the configurations.
SOURCE_BACKUP_DIRS=("config/has" "data/")

create_backup() {

	local dest="$1"
	echo "Create backup to ${dest}"
	shift
	tar -czf "${dest}" "$@"
}

prune_backups() {

	local path="$1"
	local duration_days="$2"
	echo "Prune backups older then ${duration_days} days"
	/usr/bin/find "$path" -type f -name '*.tar.gz' -mtime +"$duration_days" -delete
}

backup_filename="backup_$(date +%Y-%m-%d_%H-%M).tar.gz"
mkdir -p "${TARGET_BACKUP_DIR}"
backup_path="${TARGET_BACKUP_DIR}/${backup_filename}"

create_backup "${backup_path}" "${SOURCE_BACKUP_DIRS[@]}"
prune_backups "${backup_path}" "${DAYS_TO_RETAIN}"

echo "Backup done"
