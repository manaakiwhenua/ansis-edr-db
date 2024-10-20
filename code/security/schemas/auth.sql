create schema if not exists auth authorization edr_wheel;  -- authentication and authorisation
comment on schema auth
    is 'The `auth` schema holds tables, views and functions used to manage user identity, authentication and authorisation.';