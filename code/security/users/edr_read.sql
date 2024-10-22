-- edr_read group role
create role edr_read inherit bypassrls nosuperuser nocreatedb nocreaterole noreplication nologin;
comment on role edr_read is 'The data reader with access to table contents (can select records). Can access views and functions that return data. Group role only, usage rights may be granted to login roles authenticated using PAM. Because it is not subject to role level security, the role should only be granted to managed system users that monitor the database or summarise it for reporting.';