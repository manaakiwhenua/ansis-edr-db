-- drop view if exists sys.doc_schema cascade;
create or replace view sys.doc_schema as
    select
        nspname as schema_name,
        obj_description(oid) as schema_description
    from
        pg_catalog.pg_namespace
    where
        nspname in ('auth', 'data', 'cm', 'reg', 'sys', 'voc')
    order by
        nspname;
alter table sys.doc_schema owner to edr_wheel;
grant select on table sys.doc_schema to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_schema
    is 'Documentation of EDR defined database schemata.';
comment on column sys.doc_schema.schema_name
    is 'The name of the database schema.';
comment on column sys.doc_schema.schema_description
    is 'The description of the database schema.';