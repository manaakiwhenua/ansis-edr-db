-- drop view if exists working.attribute__domain;
create or replace view working.attribute__domain as
select
    gen_random_uuid() as id,
    pd.attribute_id,
    pd.class_id,
    pd.constraint__multiplicity,
    null::uuid as constraint__value_collection_id,
    null::uuid as constraint__value_unit_collection_id,
    null::uuid as constraint__procedure_collection_id,
    null::uuid as constraint__agent_collection_id
from
    working.property__domain pd
where
    not (pd.attribute_id ~ '_rel')
    and pd.attribute_id not in ('./sosa.json#/$defs/usedProcedure/$defs/Enumeration', './base.json#/$defs/pointer');
alter table working.attribute__domain owner to edr_wheel;
grant select on table working.attribute__domain to edr_admin, edr_jwt, edr_edit, edr_read;

