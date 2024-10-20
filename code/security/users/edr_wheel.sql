-- edr_wheel group role
create role edr_wheel nosuperuser bypassrls inherit createdb createrole replication nologin;
comment on role edr_wheel is 'The database owner/administrator with full control of the database and objects therein. Group role only, usage rights will be only be granted to known MWLR login roles authenticated using PAM.';