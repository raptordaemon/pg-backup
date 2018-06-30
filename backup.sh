#!/bin/bash

BACKUPS_PATH=${BACKUPS_PATH:-/backups}
THRESHOLD=$(date -d "7 days ago" +%Y%m%d%H%M)
PGUSER=${PGUSER:-postgres}
PGPASS=${PGPASS:-password}
PGHOST=${PGHOST:-postgres}
PGPORT=${PGPORT:-5432}


## https://unix.stackexchange.com/questions/191632/how-to-delete-old-backups-based-on-a-date-in-file-name
echo "Cleaning up older backups..."
find ${BACKUPS_PATH} -maxdepth 1 -type f -print0  | while IFS= read -d '' -r file
do
    ## Does this file name match the pattern (13 digits, then .zip)?
    if [[ "$(basename "$file")" =~ ^[0-9]{12}.sql.gz$ ]]
    then
        ## Delete the file if it's older than the $THR
        if [ "$(basename "$file" .sql.gz)" -le "$THRESHOLD" ]
        then
            rm -v -- "$file"
        fi
    fi
done


echo "$PGHOST:$PGPORT:*:$PGUSER:$PGPASS" > ~/.pgpass
chmod 0600 ~/.pgpass

echo "Creating backup..."
pg_dumpall -U $PGUSER -h $PGHOST -p $PGPORT -w -c | gzip -9 > $BACKUPS_PATH/`date +%Y%m%d%H%M`.sql.gz

RETVAL=$?

if [ "$RETVAL" == 0 ]; then
	echo Backup finished successfully.
	exit 0 
else
	echo Backup failed with errors!
	exit 1
fi