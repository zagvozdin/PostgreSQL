create or replace function same_indicies() returns table ("Schema" varchar, "Table" varchar, "Column" varchar, "Drop command" varchar, "Create command" varchar) as
$$
 declare
   schename varchar;
   tabname varchar;
   colname varchar;
   cnt int;
begin
  for schename, tabname, colname, cnt in  
        select
            idxs.schemaname as "schema",
            tbl.relname as "table",
            col.attname as "column",
            count(9) as "cnt"
        from
            pg_index i
        join
            pg_attribute col on col.attrelid = i.indrelid and col.attnum = any(i.indkey)
        join
            pg_class idx on idx.oid = i.indexrelid
        join
            pg_class tbl on tbl.oid = i.indrelid
        join
            pg_indexes idxs on idxs.indexname = idx.relname
        join
            pg_namespace sch on sch.oid = tbl.relnamespace
        where
            tbl.relkind = 'r'
            and idx.relnatts = 1
            and sch.nspname = idxs.schemaname
        group by
            "schema","table","column"
        having
            count(9) > 1
      loop
        for "Schema", "Table", "Column", "Drop command", "Create command" in
                    select
                        idxs.schemaname,
                        tbl.relname,
                        col.attname,
                        'drop index ' || idxs.schemaname || '.' || idxs.indexname || ';',  
                        idxs.indexdef as "Index definition"
                    from
                        pg_index i, pg_attribute col, pg_class idx, pg_class tbl, pg_indexes idxs, pg_namespace ns
                    where
                        col.attrelid = i.indrelid and col.attnum = any(i.indkey) 
                        and ns.oid = idx.relnamespace
                        and idxs.indexname = idx.relname and idxs.schemaname = ns.nspname and idxs.tablename = tbl.relname
                        and tbl.oid = i.indrelid
                        and idx.oid = i.indexrelid 
                        and tbl.relkind = 'r'
                        and ns.nspname = schename
                        and tbl.relname = tabname
                        and col.attname = colname
                        and idx.relnamespace = ns.oid
                        and length(cast(i.indkey as text)) < 3
            loop
                return next;
            end loop;
      end loop;
  return;
end
$$ language plpgsql;
