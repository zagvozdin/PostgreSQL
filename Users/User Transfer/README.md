Scripts for transfer users from one DB to another.

user_transfer_source.sh on source DB generate list of all users and their DDL
user_transfer_destination.sh on destination DB create absent users and execute their DDL using data from previous script
