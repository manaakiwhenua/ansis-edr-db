# EDR Sample data

This folder may contain sample data for the datastore. The files are a set of SQL `insert`
statements that add content to the database tables. Files need to be run in the order of the file
name prefix (01-, 02- etc.) as some sample data may depend on values that were loaded by an earlier
script.

Each script truncates the tables it is loading data into so we can start afresh. The `truncate`
statements `cascade` to related tables, because referential integrity.