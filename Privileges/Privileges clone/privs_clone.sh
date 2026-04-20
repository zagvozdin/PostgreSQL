################################
## privs_clone.sh
################################
#!/bin/bash
# v 1.4

DIR=$(dirname $0)
file=$(basename $0)
fileTIME=$DIR/$file.time.log

DB_SRC="eircm_hotfix_old"
DB_DST="eircm_hotfix"
USER="postgres"
FILE_GRANT_TAB_FUNC=$DIR/grants_table_function_clone.sql
FILE_GRANT_SCHEMA=$DIR/grants_schema_clone.sql

echo -e "\nGrants transfer $DB_SRC -> $DB_DST\n"
read -p "press Enter"

date '+%e %B %Y' >> $fileTIME
date >> $fileTIME

echo -e "\nGenerate grant scripts"

## tables and functions grants
psql -U$USER -d$DB_SRC -At -F '' <<'EOSQL' > $FILE_GRANT_TAB_FUNC
select
  'grant ' || privilege_type || ' on ' || table_schema || '.' || table_name || ' to "' || grantee || '";'
from information_schema.role_table_grants
where table_schema not in ('pg_catalog', 'information_schema') and grantee!='PUBLIC';
select
  'grant ' || privilege_type || ' on ' || table_schema || '.' || table_name || ' to ' || grantee || ';'
from information_schema.role_table_grants
where table_schema not in ('pg_catalog', 'information_schema') and grantee='PUBLIC';
select
  'grant execute on function ' || n.nspname || '.' || p.proname || '(' ||
  pg_get_function_identity_arguments(p.oid) || ') to "' || r.rolname || '";'
from pg_proc p
join pg_namespace n on p.pronamespace = n.oid
join pg_roles r on has_function_privilege(r.rolname, p.oid, 'EXECUTE')
where n.nspname not in ('pg_catalog', 'information_schema') and p.prokind<>'p';
select
  'grant execute on procedure ' || n.nspname || '.' || p.proname || '(' ||
  pg_get_function_identity_arguments(p.oid) || ') to "' || r.rolname || '";'
from pg_proc p
join pg_namespace n on p.pronamespace = n.oid
join pg_roles r on has_function_privilege(r.rolname, p.oid, 'EXECUTE')
where n.nspname not in ('pg_catalog', 'information_schema') and p.prokind='p';
EOSQL

## schemas grants
psql -U$USER -d$DB_SRC -At -F '' <<'EOSQL' > $FILE_GRANT_SCHEMA
select 'grant ' || privilege_type || ' on schema ' || nspname || ' to "' || e.usename || '";'
from pg_namespace
join lateral (select * from aclexplode(nspacl) as x) a
      on true
    join pg_user e
      on a.grantee = e.usesysid
    join pg_user r
      on a.grantor = r.usesysid;
EOSQL

TAB_FUNC="psql -U$USER -d$DB_DST -f$FILE_GRANT_TAB_FUNC 2>$FILE_GRANT_TAB_FUNC.err >/dev/null"
SCHEMA="psql -U$USER -d$DB_DST -f$FILE_GRANT_SCHEMA 2>$FILE_GRANT_SCHEMA.err >/dev/null"

echo -e "\t$TAB_FUNC"
echo -e "\t$SCHEMA"

lines=`cat $FILE_GRANT_TAB_FUNC | wc -l`
echo -e "\nExecute $TAB_FUNC with $lines lines"
eval $TAB_FUNC

lines=`cat $FILE_GRANT_SCHEMA | wc -l`
echo -e "Execute $SCHEMA with $lines lines"
eval $SCHEMA

date >> $fileTIME

echo -e "\nAll done.\n"
