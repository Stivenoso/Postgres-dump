#!/bin/bash
set -e

USER="postgres"
HOST="localhost"
BACKUP_DIRECTORY="/home/stephen/backups"

CURRENT_DATE=$(date "+%Y%m%d")

if pg_dumpall  -U $USER | gzip - > $BACKUP_DIRECTORY/cluster\_$CURRENT_DATE.sql.gz; then
   echo "dumpall successful"
else
   echo "dumpall failed" && curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Creating DUMP failed"
    exit
fi

if mcli cp --recursive /home/stephen/backups/ play/dump-bucket/; then
    curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Loaded DUMP successfully"
else
     curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Loading DUMP failed"
fi



#stored here https://play.min.io:9443/browser/dump-bucket

