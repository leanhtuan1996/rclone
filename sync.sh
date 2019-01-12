#!/bin/sh

set -e

echo "INFO: Starting sync.sh pid $$ $(date)"

if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
  echo "WARNING: A previous sync is still running. Skipping new sync command."
else

echo $$ > /tmp/sync.pid

export BACKUP_DAY=$( date '+%a' )

if [ -z "$SYNC_SRC_TO_ZIP" ]
then
  echo "INFO: No SYNC_SRC_TO_ZIP found. Stopping to archive folder"
else
  if test "$(ls $SYNC_SRC_TO_ZIP)"; then
    echo "INFO: Starting archive the folder $SYNC_SRC_TO_ZIP at $BACKUP_DAY"
    export BACKUP_FILE="$BACKUP_DAY.zip"

    #zip current source
    zip -r $BACKUP_FILE $SYNC_SRC_TO_ZIP

    if test "$(ls $SYNC_SRC)"; then
      cd $SYNC_SRC && rm -f *$BACKUP_DAY*.zip && cd /
      #then remove old file with `BACKUP_DAY`
    fi

    #cp this to backup folder
    cp $BACKUP_FILE $SYNC_SRC

    #then remove zip file
    rm $BACKUP_FILE
  else
    echo "ERROR: $SYNC_SRC_TO_ZIP folder not found"
  fi
fi

if test "$(rclone ls $SYNC_SRC $RCLONE_OPTS)"; then
  #zip file and cp to backup source
  # the source directory is not empty
  # it can be synced without clear data loss
  echo "INFO: Starting rclone sync $SYNC_SRC $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS"
  rclone sync $SYNC_SRC $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS

  if [ -z "$CHECK_URL" ]
  then
    echo "INFO: Define CHECK_URL with https://healthchecks.io to monitor sync job"
  else
    wget $CHECK_URL -O /dev/null
  fi
else
  echo "WARNING: Source directory is empty. Skipping sync command."
fi

rm -f /tmp/sync.pid

fi
