#!/bin/bash
# ver 1.1
DIR_BASE=/u01/backup
DAYS_KEEP=2
USER=postgres
JOBS=$((`nproc --all` / 2 + 1))
DAY_HOUR=$(date +"%Y-%b-%d_%H-%M")
DBlist=`psql -U$USER -t -c "select datname from pg_database where datname not in ('postgres','template0','template1');"`

for DB in $DBlist
do
   DIR=$DIR_BASE/$DB-$DAY_HOUR
   LOG=$DIR_BASE/$DB-$DAY_HOUR.log
   ERR=$DIR_BASE/$DB-$DAY_HOUR.err
  TIME=$DIR_BASE/$DB-$DAY_HOUR.time

  mkdir -p $DIR
  date > $TIME
  cmd="pg_dump -U$USER -d$DB -j$JOBS -Fd -f$DIR >>$LOG 2>$ERR"
  echo "$cmd" >$LOG
  eval "$cmd"
  date >> $TIME
done

find $DIR_BASE -mtime +$DAYS_KEEP -delete
