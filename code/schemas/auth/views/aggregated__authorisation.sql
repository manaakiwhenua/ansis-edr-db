-- drop view if exists auth.aggregated__authorisation cascade;
create or replace view auth.aggregated__authorisation as
with recursive _registers as (
            select
                r.id,
                r.register_id,
                r.register_type,
                r.register_label,
                r.admin_ids,
                r.editor_ids,
                r.reader_ids,
                r.denied_ids
            from
                _auth_register r
            where
                r.register_id is null
            union
            select
                r.id,
                r.register_id,
                r.register_type,
                r.register_label,
                sys.array_remove_overlap(rd.admin_ids || r.admin_ids, r.editor_ids || r.reader_ids) as admins,
                sys.array_remove_overlap(rd.editor_ids || r.editor_ids, r.reader_ids) as editors,
                rd.reader_ids || r.reader_ids as readers,
                rd.denied_ids || r.denied_ids as denied
            from
                _registers rd
                    join _auth_register r
                        on rd.id = r.register_id
        ),
        _register as (
            select
                r.id,
                r.register_id,
                'edr-register' as register_type,
                r.default_label as register_label
            from
                reg.register r
            union
            select
                d.id,
                d.register_id,
                'edr-dataset' as register_type,
                d.default_label as register_label
            from
                data.dataset d
        ),
        _authorisation as (
            select
                da.register_id,
                da.operator_id,
                da.operator_access
            from
                auth.register__authorisation da
            where
                exists ( -- exclude inactive operators
                    select
                        0
                    from
                        auth.operator op
                    where
                        op.id = da.operator_id
                        and op.active
                )
            union
            select
                da.dataset_id as register_id,
                da.operator_id,
                da.operator_access
            from
                auth.dataset__authorisation da
            where
                exists ( -- exclude inactive operators
                    select
                        0
                    from
                        auth.operator op
                    where
                        op.id = da.operator_id
                        and op.active
                )
        ),
        _auth_register as (
            select
                r.id,
                r.register_id,
                r.register_type,
                r.register_label,
                array_agg(distinct admin.operator_id) filter ( where admin.operator_id is not null ) as admin_ids,
                array_agg(distinct edit.operator_id) filter ( where edit.operator_id is not null ) as editor_ids,
                array_agg(distinct read.operator_id) filter ( where read.operator_id is not null ) as reader_ids,
                array_agg(distinct deny.operator_id) filter ( where deny.operator_id is not null ) as denied_ids
            from
                _register r
                    left join _authorisation admin
                        on r.id = admin.register_id
                           and admin.operator_access = 'admin'
                    left join _authorisation edit
                        on r.id = edit.register_id
                           and edit.operator_access = 'edit'
                    left join _authorisation read
                        on r.id = read.register_id
                           and read.operator_access = 'read'
                    left join _authorisation deny
                        on r.id = deny.register_id
                           and deny.operator_access = 'deny'
            group by
                r.id,
                r.register_id,
                r.register_type,
                r.register_label
        )
select
    d.id as register_id,
    d.register_type,
    sys.array_remove_overlap(d.admin_ids, d.denied_ids) as register_admin,
    sys.array_remove_overlap(d.admin_ids || d.editor_ids, d.denied_ids) as register_edit,
    sys.array_remove_overlap(d.admin_ids || d.editor_ids || d.reader_ids, d.denied_ids) as register_read
from
    _registers d;
alter view auth.aggregated__authorisation owner to edr_wheel;
grant select on table auth.aggregated__authorisation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view auth.aggregated__authorisation
    is 'Aggregates operators into arrays according to manage their JWT authenticated access rights on the register as granted against the register or its ancestors. Operators that have been denied access to the register, or one of its ancestors, are removed from the arrays.';
comment on column auth.aggregated__authorisation.register_id
    is 'UUID if the register the operators are authorised to access/maintain.';
comment on column auth.aggregated__authorisation.register_type
    is 'The type of register.';
comment on column auth.aggregated__authorisation.register_admin
    is 'Array of operators with admin access rights (excludes denied operators).';
comment on column auth.aggregated__authorisation.register_edit
    is 'Array of operators with edit access rights (excludes denied operators).';
comment on column auth.aggregated__authorisation.register_read
    is 'Array of operators with read access rights (excludes denied operators).';