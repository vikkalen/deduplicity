#!/bin/bash

BIN_PATH=$(readlink -f "$0")
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/.profile

function run_backup {
  . $BIN_DIR/dedup.sh "$BACKUP_DIR"
  PASSPHRASE=$SYNC_PASS duplicity --allow-source-mismatch "$BACKUP_DIR.dedup" $SYNC_DST
}

DOFILE=$SYNC_FILE
DOFILETMP=$SYNC_FILE.tmp

if [ -f "$DOFILETMP" ]
then
  run_backup "$DOFILETMP"
  DATE=$(date +"%Y%m%d%H%M")
  ARCHIVEFILE=$SYNC_FILE.$DATE.log
  cat "$DOFILETMP" >> $ARCHIVEFILE
  rm "$DOFILETMP"
fi
while true
do
  while [ -s "$DOFILE" ]
  do
    mv "$DOFILE" "$DOFILETMP"
    run_backup "$DOFILETMP"
    DATE=$(date +"%Y%m%d%H%M")
    ARCHIVEFILE=$SYNC_FILE.$DATE.log
    cat "$DOFILETMP" >> $ARCHIVEFILE
    rm "$DOFILETMP"
  done
  nc -l -p $SYNC_LISTEN_PORT > /dev/null
done
