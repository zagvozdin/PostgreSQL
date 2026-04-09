#!/bin/bash
# ver 1.2

if [ $# -ne 2 ]; then
    echo -e "\n\tUsage: $0 <coordinator ip> <dbname>"
    exit 1
fi

COORDINATOR=$1
DBNAME=$2
WLIST=worker.list
USER=postgres
PORT=5432

if [ ! -f "$WLIST" ]; then
    echo -e "\n\t$WLIST not found"
    exit 1
fi

echo -e "\nDrop citus cluster, coordinator ip $COORDINATOR, port $PORT"
echo -e "\nWorkers:"


nodes=`psql -U$USER -d$DBNAME -t -c "select nodename from pg_dist_node where groupid <> 0 order by nodename asc;"`

for node in $nodes
do
  echo -e "\t$node"
done

echo ""
read -p "press Enter"

echo ""

for node in $nodes
do
  echo $node
  psql -U$USER -h$node -p$PORT -c"drop database $DBNAME with ( force );"
  echo ""
done

echo $COORDINATOR
psql -U$USER -p$PORT -c "drop database $DBNAME with ( force );"

echo -e "\nDB $DBNAME dropped\n"
