#/bin/bash

TIMESTAMP=$(date +"%F")
BACKUP_BASE="/home/oriweb/backupwww"
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
FAILED=0

function makeBackup() {
  ORIG_DIR="/home/oriweb/www"
  echo "Backup $ORIG_DIR in $BACKUP_DIR"
  rm -rf "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"

  cp -R $ORIG_DIR $BACKUP_DIR
}

function deleteBackup() {
  DAY_BACKUP=2

  if [ $FAILED -eq 0 ] ; then
    echo "Clean backup directory $BACKUP_BASE"
    cd $BACKUP_BASE
    echo "Backup that will be deleted :"
    (ls -t |head -n $DAY_BACKUP;ls)|sort|uniq -u
    (ls -t |head -n $DAY_BACKUP;ls)|sort|uniq -u|xargs rm -rf
    echo "Clean done"
  else
    echo "No clean done, some database failed"
  fi
}

makeBackup

deleteBackup

