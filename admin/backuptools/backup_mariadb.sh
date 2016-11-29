#! /bin/bash
 
TIMESTAMP=$(date +"%F")
BACKUP_BASE="/home/mariadb/backup"
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
MYSQL_USER="BACKUPUSER"
MYSQL="mysql $1"
MYSQL_PASSWORD="PASSWORD"
MYSQLDUMP="mysqldump $1"

FAILED=0

function makeBackup() {
  rm -rf "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"

  databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

  for db in $databases; do
    echo $(date +"%Y-%m-%d %H:%M:%S")" saving $db..."
    $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$db.gz"
    EXITCODE=$?
    if [ $EXITCODE -ne 0 ] ; then 
      MESSAGE="$db failed with exit code $EXITCODE"
      FAILED=1
    else
      MESSAGE="$db saved ok"
    fi
    echo $(date +"%Y-%m-%d %H:%M:%S")" $MESSAGE"
  done
}

function deleteBackup() {

  if [ $FAILED -eq 0 ] ; then
	echo "Clean backup directory $BACKUP_BASE"
	cd $BACKUP_BASE
	echo "Backup that will be deleted :"
	(ls -t |head -n 20;ls)|sort|uniq -u
	(ls -t |head -n 20;ls)|sort|uniq -u|xargs rm -rf
	echo "Clean done"
  else
	echo "No clean done, some database failed"
  fi
}

makeBackup

deleteBackup
