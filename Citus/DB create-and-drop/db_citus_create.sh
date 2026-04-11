#!/bin/bash
# ver 1.3

if [ $# -ne 2 ]; then
    echo -e "\n\tUsage: $0 <coordinator ip> <dbname>\n"
    exit 1
fi

COORDINATOR=$1
DBNAME=$2
WLIST=worker.list
USER=postgres
PORT=5432

if [ ! -f "$WLIST" ]; then
    echo -e "\n\t$WLIST not found\n"
    exit 1
fi

echo -e "\nCreate citus cluster, coordinator ip $COORDINATOR, port $PORT"
echo -e "\nWorkers:"
while IFS= read -r ip
do
  echo -e "\t$ip"
done < "$WLIST"

echo ""
read -p "press Enter"

echo -e "\n$COORDINATOR"
psql -U$USER -p$PORT -c "create database $DBNAME;" 2>/dev/null
psql -U$USER -p$PORT -d$DBNAME -c "create extension citus;"
psql -U$USER -p$PORT -d$DBNAME -c "select citus_set_coordinator_host('$COORDINATOR', $PORT);" >/dev/null

echo ""
while IFS= read -r ip
do
    echo $ip
    psql -U$USER -h$ip -p$PORT -c "create database $DBNAME;" 2>/dev/null
    psql -U$USER -h$ip -p$PORT -d$DBNAME -c "create extension if not exists citus;"
    psql -U$USER -p$PORT -d$DBNAME -c "select * from master_add_node('$ip', $PORT);" >/dev/null
    echo ""
done < "$WLIST"

psql -U$USER -p$PORT -d$DBNAME -c "select from_nodename as \"Node\", from_nodeport as \"Port\" from citus_check_cluster_node_health() group by from_nodename, from_nodeport order by from_nodename asc;"

echo -e "DB $DBNAME created\n"
