-- pgwatch2

-- https://docs.docker.com/reference/cli/docker

create role pgwatch2;
alter role pgwatch2 connection limit 4;
grant pg_monitor to pgwatch2;

-- check for libraries
show shared_preload_libraries;
--                        shared_preload_libraries                         
-- -------------------------------------------------------------------------
--  pg_stat_statements,auto_explain,pg_stat_kcache,pg_wait_sampling,pg_cron

-- check for track_io_timing
-- show track_io_timing;
-- track_io_timing 
-- -----------------
-- on

create extension pg_stat_statements;
create extension pg_wait_sampling;
create extension pg_stat_kcache cascade;
grant execute on function pg_stat_file(text) to pgwatch2;
grant execute on function pg_stat_file(text, boolean) to pgwatch2;
grant execute on function pg_ls_dir(text) to pgwatch2;
grant execute on function pg_ls_dir(text, boolean, boolean) to pgwatch2;
grant execute on function pg_wait_sampling_reset_profile to pgwatch2;
