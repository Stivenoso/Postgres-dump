# Postgres-dump

Dumps for me located in https://play.min.io:9443/browser/dump-bucket


bot.conf file with bot and channel IDs

cron copy - simple copy of my local cron file

simple_dump.sh - bash script to dump local postgreSQL DBs


harder_dump.sh - update to previous script, requires .conf file in the same directory

In .conf you need to fill in DB to be dumped and other stuff

**Newest update**
smarter_dump.sh which uses it's own smarter_dump.conf
you can add cluster names and much more IDs for DBs to backup, but you'll need to fill in config for each base
