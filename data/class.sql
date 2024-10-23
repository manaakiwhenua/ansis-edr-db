-- drop view if exists working.class cascade;
create or replace view working.class as
select
    defs.obj ->> '@id' as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    false as abstract,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    false as root_class,
    'edr-entity' as system__type_id,
    null as system__label_template,
    null as system__default_location_attribute_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as _external_ref,
    concat('#/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') != 'array'
union all
select
    _id as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    concat(defs.key, '[', _id, ']') as identifier,
    false as abstract,
    concat(defs.obj ->> 'title', ' [', _id, ']') as label,
    defs.obj ->> 'description' as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    false as root_class,
    'edr-entity' as system__type_id,
    null as system__label_template,
    null as system__default_location_attribute_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as _external_ref,
    concat('#/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_array_elements_text(defs.obj -> '@id') _id
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array';
alter view working.class owner to edr_wheel;
grant select on table working.class to edr_admin, edr_jwt, edr_edit, edr_read;