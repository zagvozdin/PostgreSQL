create or replace function grant_readonly_privileges(username text)
returns void as $$
declare
    schemaname text;
begin
    -- grants per schema
    for schemaname in
        select nspname
        from pg_catalog.pg_namespace
        where nspname not like 'pg_%' and nspname not like 'information_schema%'
    loop
        -- in case of citus extension 
	begin
	   set local citus.multi_shard_modify_mode to 'sequential';
	exception
	   when others then
	      null;
	end;

        execute format('grant usage on schema %I to %I', schemaname, username);
        execute format('grant select on all tables in schema %I to %I', schemaname, username);
        execute format('grant usage on all sequences in schema %I to %I', schemaname, username);
        execute format('grant execute on all functions in schema %I to %I', schemaname, username);

        execute format('alter default privileges in schema %I grant select on tables to %I', schemaname, username);
        execute format('alter default privileges in schema %I grant usage on sequences to %I', schemaname, username);
	execute format('alter default privileges in schema %I grant execute on functions to %I', schemaname, username);

    end loop;
end;
$$ language plpgsql;
