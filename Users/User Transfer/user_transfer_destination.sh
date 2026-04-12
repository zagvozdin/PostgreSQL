#!/bin/bash
# ver 1.1

USER="postgres"
LIST="users.txt"
LISTDDL="users_ddl.txt"

LISTdest="users_dest.txt"
psql -U$USER -t -c"select usename from pg_user order by 1 asc" > $LISTdest

n=0
for U in `cat $LIST`; do
  check=`egrep "$U" "$LISTdest"`
  if [ "$check" = "" ]; then
    let n++
    echo -e "\n$U"
    f="DDL_$U.sql"
    egrep "$U" $LISTDDL >$f
    psql -U$USER -f$f 
  fi
done

echo -e "\n$n users transferred\n"
