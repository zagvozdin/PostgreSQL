create or replace function grant_all_privileges(p_username text, p_schema text default null)
returns table("Schema" varchar) as $$
-- ver 1.1
begin
  if p_schema is null then
    p_schema = '%';
  end if;

  for "Schema" in
    select nspname from pg_catalog.pg_namespace
    where nspname not like 'pg_%' and nspname not like 'information_schema%' and nspname like p_schema order by nspname asc
    loop
      -- in case of citus extension 
      begin
        set local citus.multi_shard_modify_mode to 'sequential';
      exception
        when others then null;
      end;
      -- raise notice 'grant all on schema % from %;', "Schema", p_username;
      execute format('grant all on schema %I to %I', "Schema", p_username);
      execute format('grant all privileges on all tables in schema %I to %I', "Schema", p_username);
      execute format('grant all privileges on all sequences in schema %I to %I', "Schema", p_username);
      execute format('grant execute on all functions in schema %I to %I', "Schema", p_username);
      execute format('grant execute on all procedures in schema %I to %I', "Schema", p_username);

      execute format('alter default privileges in schema %I grant all on tables to %I', "Schema", p_username);
      execute format('alter default privileges in schema %I grant all on sequences to %I', "Schema", p_username);
      execute format('alter default privileges in schema %I grant execute on functions to %I', "Schema", p_username);

      return next;
    end loop;
end;
$$ language plpgsql;
