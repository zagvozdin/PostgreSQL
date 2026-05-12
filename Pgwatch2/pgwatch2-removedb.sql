-- eirc3-monitor01p# docker exec -it 6a43c8be4e26 bash
-- root@6a43c8be4e26:/# su - postgres
-- root@6a43c8be4e26:/# psql
-- postgres=# \c pgwatch2_metrics
-- pgwatch2_metrics=# delete from db_stats where dbname='db_to_remove';

-- deletion of table stats, not DBs from list, need to wait for deletion will apply
\c pgwatch2_metrics
delete from db_stats where dbname='db_to_remove';

-- DBs deletion from list
-- pgwatch2_metrics=# delete from admin.all_distinct_dbname_metrics where dbname like 'shard_eircm_%';
-- DELETE 168
\c pgwatch2_metrics
delete from admin.all_distinct_dbname_metrics where dbname like 'db_to_remove';
