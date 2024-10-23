-- drop view if exists working.attribute__domain;
create or replace view working.attribute__domain as
select
    gen_random_uuid() as id,
    pd.definition_id as attribute_id,
    pd.class_id,
    pd.constraint__multiplicity,
    null as constraint__value_collection_id,
    null as constraint__value_unit_collection_id,
    null as constraint__procedure_collection_id,
    null as constraint__agent_collection_id
from
    working.property__domain pd
        left join working.attribute atte on pd.definition_id = atte._external_ref
        left join working.attribute atti on pd.definition_id = atti._internal_ref
where
    not (pd.definition_id ~ '_rel');
alter table working.attribute__domain owner to edr_wheel;
grant select on table working.attribute__domain to edr_admin, edr_jwt, edr_edit, edr_read;

