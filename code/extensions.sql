-- install extensions
create extension if not exists postgis schema public;
create extension if not exists postgis_topology;
create extension if not exists btree_gist schema public;
create extension if not exists citext schema public;
create extension if not exists tablefunc schema public;
create extension if not exists pg_trgm schema public;
create extension if not exists plpython3u schema pg_catalog;
create extension if not exists h3 schema public;
create extension if not exists h3_postgis cascade schema public;
