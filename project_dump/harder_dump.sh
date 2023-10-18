#!/usr/bin/env bash


set -e


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


if [ -f "${HOME}/.harder_dump.conf" ]; then
    source ${HOME}/.harder_dump.conf
else
    source $DIR/.conf
fi


NOW=$(date +"%Y-%m-%d-at-%H-%M-%S")

IFS=',' read -ra DBS <<< "$PG_DATABASES"

echo " * Backup in progress.,.";


for db in "${DBS[@]}"; do
    FILENAME="$NOW"_"$db"

    echo "   -> backing up $db..."

    pg_dump -Fc -h $PG_HOST -U $PG_USER -p $PG_PORT $db > /tmp/"$FILENAME".dump

    mcli cp --recursive /tmp/"$FILENAME".dump  $S3_PATH/

    rm /tmp/"$FILENAME".dump

    echo "      ...database $db has been backed up"
done

echo " * Deleting old backups...";

mcli rm --recursive --older-than 2d --force $S3_PATH/

curl -s -X POST https://api.telegram.org/bot6331139013:AAEfqXLK3w1HP9p1wp5mVEWW8EhpXHNU4AQ/sendMessage -d chat_id=-1001923398584 -d text="Loaded DUMP successfully"

echo ""
echo "...done!";
echo ""
