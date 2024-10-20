-- drop view if exists sys.doc_table cascade;
create or replace view sys.doc_table as
    select
        table_schema as schema_name,
        table_name,
        lower(replace(table_type,'BASE ', '')) as table_type,
        obj_description(format('%s.%s',table_schema,table_name)::regclass::oid, 'pg_class') as table_description
    from
        information_schema.tables
    where
        table_schema in ('auth', 'data', 'cm', 'reg', 'sys', 'voc')
    order by
        table_schema,
        table_name;
alter table sys.doc_table owner to edr_wheel;
grant select on table sys.doc_table to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_table is 'Documentation of EDR database tables.';
comment on column sys.doc_table.schema_name
    is 'The name of the database schema that owns the table.';
comment on column sys.doc_table.table_name
    is 'The name of the table.';
comment on column sys.doc_table.table_type
    is 'The type of the table. E.g. table or view.';
comment on column sys.doc_table.table_description
    is 'The description of the table.';