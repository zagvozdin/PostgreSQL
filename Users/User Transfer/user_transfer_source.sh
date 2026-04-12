#!/bin/bash
# ver 1.1

USER="postgres"
LIST="users.txt"
LISTDDL="users_ddl.txt"
Q1="select usename from pg_user order by 1 asc;"
CMD1="pg_dumpall --globals-only -U$USER >$LISTDDL"

psql -U$USER -t -c"$Q1" >$LIST;
n=`cat "$LIST" | wc -l`

if [ $n -eq 0 ]; then
  echo -e "\n\tError getting users\n"
  exit 1
fi

echo -e "\n$n users found"
eval $CMD1

echo -e "\nFiles created:"
ls $LIST $LISTDDL

echo ""

