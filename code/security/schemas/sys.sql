create schema if not exists sys authorization edr_wheel;  -- system tools
comment on schema sys
    is 'The `sys` schema holds tables, views and functions used throughout the database. These support: database documentation; essential operations relating to user identity, authentication and authorisation; and the generation of resource identifiers.';