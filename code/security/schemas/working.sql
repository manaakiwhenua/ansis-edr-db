create schema if not exists working authorization edr_wheel;  -- working/black ops location
comment on schema working
    is 'The `working` schema holds _temporary_ tables, views and functions used when managing or updating the database. This schema will be periodically purged so _do not use for data that must endure.';