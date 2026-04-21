create or replace function revoke_all_privileges(p_username text, p_schema text default null)
returns table("Schema" varchar) as $$
-- ver 1.1
begin
  if p_schema is null then
    p_schema = '%';
  end if;

  for "Schema" in
    select nspname from pg_catalog.pg_namespace
    where nspname not like 'pg_%' and nspname not like 'information_schema%' and nspname like p_schema  order by nspname asc
    loop
      -- in case of citus extension 
      begin
        set local citus.multi_shard_modify_mode to 'sequential';
      exception
        when others then null;
      end;
      -- raise notice 'revoke all on schema % from %;', "Schema", p_username;
      execute format('revoke all on schema %I from %I', "Schema", p_username);
      execute format('revoke all privileges on all tables in schema %I from %I', "Schema", p_username);
      execute format('revoke all privileges on all sequences in schema %I from %I', "Schema", p_username);
      execute format('revoke execute on all functions in schema %I from %I', "Schema", p_username);
      execute format('revoke execute on all procedures in schema %I from %I', "Schema", p_username);

      execute format('alter default privileges in schema %I revoke all on tables from %I', "Schema", p_username);
      execute format('alter default privileges in schema %I revoke all on sequences from %I', "Schema", p_username);
      execute format('alter default privileges in schema %I revoke execute on functions from %I', "Schema", p_username);

      return next;
    end loop;
END;
$$ language plpgsql;
