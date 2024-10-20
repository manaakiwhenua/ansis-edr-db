-- drop view if exists sys.doc_function cascade;
create or replace view sys.doc_function as
    select
        pgns.nspname as schema_name,
        pgpr.proname as function_name,
        case
            when pgpr.prokind = 'f' then 'function'
            when pgpr.prokind = 'p' then 'procedure'
        end as function_type,
        array_to_string(pgpr.proargnames, '; ') as function_arguments,
        format_type (pgpr.prorettype,null) as function_returns,
        obj_description(pgpr.oid) as function_description
    from
        pg_catalog.pg_proc pgpr
            join pg_catalog.pg_namespace pgns on pgns.oid = pgpr.pronamespace
    where
            pgns.nspname in ('auth', 'data', 'cm', 'reg', 'sys', 'voc')
    order by
        pgns.nspname,
        pgpr.proname;
alter table sys.doc_function owner to edr_wheel;
grant select on table sys.doc_function to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_function
    is 'Documentation of EDR database functions.';
comment on column sys.doc_function.schema_name
    is 'The name of the database schema that owns the function.';
comment on column sys.doc_function.function_name
    is 'The name of the constraint.';
comment on column sys.doc_function.function_type
    is 'The type of function (function or procedure).';
comment on column sys.doc_function.function_arguments
    is 'The arguments taken by the function.';
comment on column sys.doc_function.function_returns
    is 'The return type of the function.';
comment on column sys.doc_function.function_description
    is 'The description of the function.';