create or replace function revoke_all_privileges(username text)
returns void as $$
declare
    schemaname text;
begin
    for schemaname in
        select nspname
        from pg_catalog.pg_namespace
        where nspname not like 'pg_%' and nspname not like 'information_schema%'
    loop
        execute format('revoke all on schema %I from %I', schemaname, username);
        execute format('revoke all privileges on all tables in schema %I from %I', schemaname, username);
        execute format('revoke all privileges on all sequences in schema %I from %I', schemaname, username);
        execute format('revoke execute on all functions in schema %I from %I', schemaname, username);

        execute format('alter default privileges in schema %I revoke all on tables from %I', schemaname, username);
        execute format('alter default privileges in schema %I revoke all on sequences from %I', schemaname, username);
        execute format('alter default privileges in schema %I revoke execute on functions from %I', schemaname, username);
    end loop;
END;
$$ language plpgsql;
