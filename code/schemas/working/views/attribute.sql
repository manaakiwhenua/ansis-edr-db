-- drop view if exists working.attribute cascade;
create or replace view working.attribute as
select
    concat('./', aj.file_name, '#/$defs/', defs.key, '/$defs/' || sub.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    concat(defs.obj ->> 'title', ' - ' || sub.key) as label,
    case when sub.obj is not null
         then concat(defs.obj ->> 'description', ' ', sub.obj ->> 'description')
         else defs.obj ->> 'description'
    end as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    'edr-assertion' as system__type_id,
    concat('#/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
        left join jsonb_each(defs.obj #> '{$defs}'::text[]) sub(key, obj) on true
where
    aj.file_name in ('base.json', 'prov.json', 'qudt.json')
    and coalesce(defs.obj ->> 'type', 'not an object') != 'object'
union
select
    concat('./', aj.file_name, '#/$defs/', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    'edr-assertion' as system__type_id,
    concat('#/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs,Project,properties}'::text[]) defs(key, obj)
where
    aj.file_name in ('proj.json')
    and coalesce(defs.obj ->> '$ref', './base.json#/$defs/pointer') != './base.json#/$defs/pointer'
union
select
    concat('./', aj.file_name, '#/$defs/', defs.key, '/$defs/' || sub.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    concat(defs.obj ->> 'title', ' - ' || sub.key) as label,
    case when sub.obj is not null
         then concat(defs.obj ->> 'description', ' ', sub.obj ->> 'description')
         else defs.obj ->> 'description'
    end as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    case when defs.key = 'geometry'
         then 'edr-observation'
         else 'edr-assertion'
    end as system__type_id,
    concat('#/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
        left join jsonb_each(defs.obj #> '{$defs}'::text[]) sub(key, obj) on true
where
    aj.file_name in ('geo.json')
union
select
    concat('./', aj.file_name, '#/$defs/', defs.key, '/$defs/' || sub.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    concat(defs.obj ->> 'title', ' - ' || sub.key) as label,
    case when sub.obj is not null
         then concat(defs.obj ->> 'description', ' ', sub.obj ->> 'description')
         else defs.obj ->> 'description'
    end as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    case when defs.key = 'result'
         then 'edr-observation'
         else 'edr-assertion'
    end as system__type_id,
    concat('#/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
        left join jsonb_each(defs.obj #> '{$defs}'::text[]) sub(key, obj) on true
where
    aj.file_name in ('sosa.json')
    and defs.key != 'Sampling'
    and coalesce(defs.obj ->> '$ref', 'not a pointer') != './base.json#/$defs/pointer'
union
select
    concat('./', aj.file_name, '#/$defs/_att/$defs/', defs.key, '/$defs/' || sub.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    concat(defs.obj ->> 'title', ' - ' || sub.key) as label,
    case when sub.obj is not null
         then concat(defs.obj ->> 'description', ' ', sub.obj ->> 'description')
         else defs.obj ->> 'description'
    end as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    'edr-assertion' as system__type_id,
    concat('#/$defs/_att/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs,_att,$defs}'::text[]) defs(key, obj)
        left join jsonb_each(defs.obj #> '{$defs}'::text[]) sub(key, obj) on true
where
    aj.file_name in ('properties.json')
union
select
    concat('./', aj.file_name, '#/$defs/_obs/$defs/', defs.key, '/$defs/' || sub.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    concat(defs.obj ->> 'title', ' - ' || sub.key) as label,
    case when sub.obj is not null
         then concat(defs.obj ->> 'description', ' ', sub.obj ->> 'description')
         else defs.obj ->> 'description'
    end as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    'edr-observation' as system__type_id,
    concat('#/$defs/_obs/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs,_obs,$defs}'::text[]) defs(key, obj)
        left join jsonb_each(defs.obj #> '{$defs}'::text[]) sub(key, obj) on true
where
    aj.file_name in ('properties.json')
union
select
    concat('./', aj.file_name, '#/$defs/', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    defs.key as identifier,
    null as data_type_id,
    false as abstract,
    false as derived,
    defs.obj ->> 'title' as label,
    defs.obj ->> 'description' as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    'edr-measurement' as system__type_id,
    concat('#/$defs/', defs.key) as _internal_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}'::text[]) defs(key, obj)
where
    aj.file_name in ('properties-chemical.json', 'properties-physical.json');
alter table working.attribute owner to edr_wheel;
grant select on table working.attribute to edr_admin, edr_jwt, edr_edit, edr_read;