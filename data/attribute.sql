-- drop view if exists working.attribute;
create or replace view working.attribute as
select
    coalesce(defs.obj ->> '@id', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as defintion,
    defs.obj ->> '$comment' as editorial_note,
    null as rdf_match,
    null as see_also,
    null as constraints,
    'edr-assertion' as system__type_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as _external_ref,
    concat('#/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('base.json', 'prov.json', 'qudt.json')
    and defs.obj ->> 'type' != 'object'
union
select
    coalesce(defs.obj ->> '@id', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as defintion,
    defs.obj ->> '$comment' as editorial_note,
    null as rdf_match,
    null as see_also,
    null as constraints,
    case when defs.key = 'geometry'
         then 'edr-observation'
         else 'edr-assertion'
    end as system__type_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as _external_ref,
    concat('#/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('geo.json')
union
select
    coalesce(defs.obj ->> '@id', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as defintion,
    defs.obj ->> '$comment' as editorial_note,
    null as rdf_match,
    null as see_also,
    null as constraints,
    case when defs.key = 'result'
         then 'edr-observation'
         else 'edr-assertion'
    end as system__type_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as _external_ref,
    concat('#/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('sosa.json')
    and defs.key not in ('Sampling', 'sampleOf')
union
select
    coalesce(defs.obj ->> '@id', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as defintion,
    defs.obj ->> '$comment' as editorial_note,
    null as rdf_match,
    null as see_also,
    null as constraints,
    'edr-assertion' as system__type_id,
    concat('./', aj.file_name, '#/$defs/_att/$defs/', defs.key) as _external_ref,
    concat('#/$defs/_att/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs,_att,$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('properties.json')
union
select
    coalesce(defs.obj ->> '@id', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as defintion,
    defs.obj ->> '$comment' as editorial_note,
    null as rdf_match,
    null as see_also,
    null as constraints,
    'edr-observation' as system__type_id,
    concat('./', aj.file_name, '#/$defs/_obs/$defs/', defs.key) as _external_ref,
    concat('#/$defs/_obs/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs,_obs,$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('properties.json')
union
select
    defs.key as id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as defintion,
    defs.obj ->> '$comment' as editorial_note,
    null as rdf_match,
    null as see_also,
    null as constraints,
    'edr-measurement' as system__type_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as _external_ref,
    concat('#/$defs/', defs.key) as _internal_ref
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('properties-chemical.json', 'properties-physical.json');
alter table working.attribute owner to edr_wheel;
grant select on table working.attribute to edr_admin, edr_jwt, edr_edit, edr_read;