-- drop view if exists working.class cascade;
create or replace view working.class as
select
    concat('./', aj.file_name, '#/$defs/', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    false as abstract,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as definition,
    defs.obj ->> '$comment' as editorial_note,
    case when jsonb_typeof(defs.obj -> '@id') = 'array'
         then replace(replace(replace(defs.obj ->> '@id', '[', '{'), ']', '}'), '"', '')::text[]
         else case when defs.obj ->> '@id' is not null then array[defs.obj ->> '@id'] end
    end as rdf_match,
    null::text[] as see_also,
    false as root_class,
    'edr-entity' as system__type_id,
    null as system__label_template,
    null as system__default_location_attribute_id,
    concat('#/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object';
alter view working.class owner to edr_wheel;
grant select on table working.class to edr_admin, edr_jwt, edr_edit, edr_read;