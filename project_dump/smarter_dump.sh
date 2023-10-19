#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/smarter_dump.conf"

NOW=$(date +"%Y-%m-%d-at-%H-%M-%S")

IFS=',' read -ra DB_ENTRIES <<< "$PG_DATABASES"

for entry in "${DB_ENTRIES[@]}"; do
    IFS=':' read -ra DB_PARAMS <<< "$entry"
    NAME="${DB_PARAMS[0]}"
    HOST="${DB_PARAMS[1]}"
    PORT="${DB_PARAMS[2]}"
    USER="${DB_PARAMS[3]}"
    CLUSTER="${DB_PARAMS[4]}"

    FILENAME="$NOW"_"$NAME"

    echo " * Backing up $NAME on $HOST:$PORT..."

    if pg_dump -Fc -h "$HOST" -p "$PORT" -U "$USER" "$NAME" > /tmp/"$FILENAME".dump; then
        echo "      ...database $NAME has been backed up successfully"
        curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Loaded DUMP for $NAME successfully ✅"
        mcli cp --recursive /tmp/"$FILENAME".dump "$S3_PATH/"
        rm /tmp/"$FILENAME".dump
    else
        echo "      ...failed to backup database $NAME"
        curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Failed to load DUMP for $NAME ❌"
    fi
done

echo " * Deleting old backups..."

if mcli rm --recursive --older-than 2d --force "$S3_PATH/"; then
    echo "      ...old backups have been deleted successfully"
else
    echo "      ...failed to delete old backups"
    curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Failed to delete old backups ❌"
fi

echo " * Backup process completed"
curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Backup process completed ✅"
