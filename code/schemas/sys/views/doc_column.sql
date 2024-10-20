-- drop view if exists sys.doc_column cascade;
create or replace view sys.doc_column as
    with _primary_keys as (
            select
                tc.table_schema,
                tc.table_name,
                kcu.column_name,
                'PK' as key
            from
                information_schema.table_constraints  tc
                    join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
                                                                and tc.table_schema = kcu.table_schema
            where
                tc.constraint_type = 'PRIMARY KEY'
        ),
        _foreign_keys as (
            select
                tc.table_schema,
                tc.table_name,
                kcu.column_name,
                'FK' as key,
                concat(
                        ccu.table_schema,
                        '.',
                        ccu.table_name,
                        '.',
                        ccu.column_name
                ) as fk_references
            from
                information_schema.table_constraints  tc
                    join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
                                                                and tc.table_schema = kcu.table_schema
                    join information_schema.constraint_column_usage ccu on ccu.constraint_name = tc.constraint_name
            where
                tc.constraint_type = 'FOREIGN KEY'
                AND tc.table_schema='cm'
        )
    select
        isc.table_schema as schema_name,
        isc.table_name,
        isc.column_name,
        concat_ws('/',pk.key,fk.key) as key,
        fk.fk_references,
        case
            when isc.data_type = 'ARRAY'
            then concat(replace(isc.udt_name, '_', ''), '[]')
            else isc.data_type
        end as data_type,
        isc.is_nullable,
        case
            when isc.column_default ~ '\:\:' then split_part(isc.column_default,':',1)
            else lower(isc.column_default)
        end as column_default,
        pg_catalog.col_description(format('%s.%s',isc.table_schema,isc.table_name)::regclass::oid,isc.ordinal_position) as column_description
    from
        information_schema.columns isc
            left join _foreign_keys fk on isc.table_schema = fk.table_schema
                                      and isc.table_name = fk.table_name
                                      and isc.column_name = fk.column_name
            left join _primary_keys pk on isc.table_schema = pk.table_schema
                                      and isc.table_name = pk.table_name
                                      and isc.column_name = pk.column_name
    where
        isc.table_schema in ('auth', 'data', 'cm', 'reg', 'sys', 'voc')
    order by
        isc.table_schema,
        isc.table_name,
        isc.ordinal_position;
alter table sys.doc_column owner to edr_wheel;
grant select on table sys.doc_column to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_column
    is 'Documentation of columns on EDR database tables.';
comment on column sys.doc_column.schema_name
    is 'The name of the database schema that owns the table/column.';
comment on column sys.doc_column.table_name
    is 'The name of the table that owns the column.';
comment on column sys.doc_column.column_name
    is 'The name of the column.';
comment on column sys.doc_column.key
    is 'Flags whether the column is part of a primary key (PK), foreign key (FK), or both (PK/FK).';
comment on column sys.doc_column.fk_references
    is 'The path to the foreign table column referred to by the column if it is part of a foreign key.';
comment on column sys.doc_column.data_type
    is 'The column data type.';
comment on column sys.doc_column.is_nullable
    is 'Flags whether null values are allowed.';
comment on column sys.doc_column.column_default
    is 'The default value for new records. May be a function (e.g. current user), or a constant value.';
comment on column sys.doc_column.column_description
    is 'The description of the column.';