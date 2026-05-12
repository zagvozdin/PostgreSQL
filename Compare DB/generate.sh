#!/bin/bash
# v1.3
if [ "$DBNAME" = "" ]; then
  echo -e "\n\tExport DBNAME variable\n"
  exit 1;
fi
echo 'if [ "$DBNAME" = "" ]; then echo "Export DBNAME variable"; exit 1; fi' > ddl_get.sh
psql -Upostgres -d$DBNAME -t -f ./generate.sql >> ddl_get.sh
echo "tar --remove-files -cf ddl_$DBNAME.tar ./*.log" >> ddl_get.sh
echo "ls -la ddl_$DBNAME.tar" >> ddl_get.sh
chmod u+x ddl_get.sh
echo ""
ls -la ddl_get.sh
echo ""