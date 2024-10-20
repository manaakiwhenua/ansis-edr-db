-- drop view if exists sys.doc_index cascade;
create or replace view sys.doc_index as
    select
        pgix.schemaname as schema_name,
        pgix.tablename as table_name,
        pgix.indexname as index_name,
        concat_ws(
            '; ',
            case
                when pgix.indexdef ~ 'UNIQUE' then 'unique'
            end,
            regexp_replace(pgix.indexdef,'^.*USING\s(.*)\s\(.*$','\1')
        ) as index_type,
        regexp_replace(pgix.indexdef,'^.*\((.*)\)$','\1') as index_columns
    from
        pg_catalog.pg_indexes pgix
    where
        pgix.schemaname in ('auth', 'data', 'cm', 'reg', 'sys', 'voc')
    order by
        pgix.schemaname,
        pgix.tablename,
        pgix.indexname;
alter table sys.doc_index owner to edr_wheel;
grant select on table sys.doc_index to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_index
    is 'Documentation of indexes applied to EDR database tables.';
comment on column sys.doc_index.schema_name
    is 'The name of the database schema that owns the table/index.';
comment on column sys.doc_index.table_name
    is 'The name of the table that owns the index.';
comment on column sys.doc_index.index_name
    is 'The name of the index.';
comment on column sys.doc_index.index_type
    is 'The type of index.';
comment on column sys.doc_index.index_columns
    is 'The indexed columns.';