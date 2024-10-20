-- drop view if exists auth.aggregated__authorisation__labelled cascade;
create or replace view auth.aggregated__authorisation__labelled as
select
    coalesce(r.default_label,c.default_label) as register,
    rda.register_type,
    string_agg(distinct auth.operator__label(ds_admin), ', ') as register_admin,
    string_agg(distinct auth.operator__label(ds_edit), ', ') as register_edit,
    string_agg(distinct auth.operator__label(ds_read), ', ') as register_read
from
    auth.aggregated__authorisation rda
        left join reg.register r
            on rda.register_id = r.id
        left join data.dataset c
            on rda.register_id = c.id,
    unnest(rda.register_admin) as ds_admin,
    unnest(rda.register_edit) as ds_edit,
    unnest(rda.register_read) as ds_read
group by
    coalesce(r.default_label,c.default_label),
    rda.register_type;
alter view auth.aggregated__authorisation__labelled owner to edr_wheel;
grant select on table auth.aggregated__authorisation__labelled to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view auth.aggregated__authorisation__labelled
    is 'As per auth.aggregated__authorisation but with human (and developer) friendly labels in place of UUIDs.';
comment on column auth.aggregated__authorisation__labelled.register
    is 'Name of the register the operators are authorised to access/maintain.';
comment on column auth.aggregated__authorisation__labelled.register_type
    is 'The type of register (register or dataset).';
comment on column auth.aggregated__authorisation__labelled.register_admin
    is 'Array of operators with admin access rights (excludes denied operators).';
comment on column auth.aggregated__authorisation__labelled.register_edit
    is 'Array of operators with edit access rights (excludes denied operators).';
comment on column auth.aggregated__authorisation__labelled.register_read
    is 'Array of operators with read access rights (excludes denied operators).';