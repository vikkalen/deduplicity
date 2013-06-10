#!/bin/bash

BIN_PATH=$(readlink -f "$0")
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/.profile

USR=$SYNC_SRC_USR
SRV=$SYNC_SRC_SRV
SRC=$SYNC_SRC
DST=$BACKUP_DIR
DOFILE=$SYNC_FILE
PERIOD=$SYNC_PERIOD

while true
do
  while true; do nc -z $SRV 22 >/dev/null && break; sleep 60; done
  rsync -ac --prune-empty-dirs --out-format="%n" --delete $@ $USR@$SRV:$SRC $DST/ | grep '/' >> $DOFILE
  if [ $? -eq 0 ]
  then
    nc -q1 $SYNC_LISTEN_SRV $SYNC_LISTEN_PORT < $DOFILE
  fi
  sleep $PERIOD
done
