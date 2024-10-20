-- drop view if exists sys.doc_constraint cascade;
create or replace view sys.doc_constraint as
    select
        pgns.nspname as schema_name,
        pgcl.relname as table_name,
        pgco.conname as constraint_name,
        case
            when pgco.contype = 'u' then 'unique'
            when pgco.contype = 'c' then 'check'
        end as constraint_type,
        string_agg(c.column_name, ', ' order by c.ordinal_position) as constraint_columns,
        obj_description(pgco.oid) as constraint_description
    from
        pg_catalog.pg_constraint pgco
            join pg_catalog.pg_class pgcl on pgcl.oid = pgco.conrelid
            join pg_catalog.pg_namespace pgns on pgns.oid = pgco.connamespace
            join information_schema.constraint_column_usage ccu on pgns.nspname = ccu.table_schema
                                                               and pgcl.relname = ccu.table_name
            join information_schema.columns c on ccu.table_schema = c.table_schema
                                             and ccu.table_name = c.table_name
                                             and ccu.column_name = c.column_name
                                             and ccu.constraint_name = pgco.conname
    where
        pgns.nspname in ('auth', 'data', 'cm', 'reg', 'sys', 'voc')
        and pgco.contype not in ('p','f')
    group by
        pgns.nspname,
        pgcl.relname,
        pgco.oid,
        pgco.conname,
        pgco.contype
    order by
        pgns.nspname,
        pgcl.relname,
        pgco.conname;
alter table sys.doc_constraint owner to edr_wheel;
grant select on table sys.doc_constraint to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_constraint
    is 'Documentation of check and unique constraints applied to EDR database tables.';
comment on column sys.doc_constraint.schema_name
    is 'The name of the database schema that owns the table/constraint.';
comment on column sys.doc_constraint.table_name
    is 'The name of the table that owns the constraint.';
comment on column sys.doc_constraint.constraint_name
    is 'The name of the constraint.';
comment on column sys.doc_constraint.constraint_type
    is 'The type of constraint (check or unique).';
comment on column sys.doc_constraint.constraint_columns
    is 'The columns governed by the constraint.';
comment on column sys.doc_constraint.constraint_description
    is 'The description of the constraint.';