-- edr_admin group role
create role edr_admin bypassrls inherit nosuperuser nocreatedb nocreaterole noreplication nologin;
comment on role edr_admin is 'The data administrator with full control of table contents. Distinguishable from the edr_edit role in that it can truncate tables. Group role only, usage rights will be only be granted to known MWLR login roles authenticated using PAM.';