Extract tables DDL from database and compare it using diff.

How it works:
generate.sh using generate.sql for to produce script ddl_get.sh, which, in turn, after it's execution generates each table DDL in separate file and pack it using tar (using local connection with postgres user login).
Then diff.sh compare two directories with untared tables DDL.
