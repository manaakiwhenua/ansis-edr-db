-- drop view if exists working.property__domain;
create or replace view working.property__domain as
select
    concat(defs.obj ->> '@id', '.', defs.key) as id,
    props.key as property_id,
    case when props.obj ->> 'type' = 'array'
         then props.obj #>> '{items,$ref}'
         else props.obj ->> '$ref'
    end as definition_id,
    defs.obj ->> '@id' as class_id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    array[
        case when defs.obj -> 'required' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj ->> 'type' = 'array' then null else 1 end
    ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_each(defs.obj #> '{properties}') props(key,obj)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') != 'array'
union all
select
    concat(_id, '.', defs.key) as id,
    props.key as property_id,
    case when props.obj ->> 'type' = 'array'
         then props.obj #>> '{items,$ref}'
         else props.obj ->> '$ref'
    end as definition_id,
    _id as class_id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    array[
        case when defs.obj -> 'required' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj ->> 'type' = 'array' then null else 1 end
    ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_each(defs.obj #> '{properties}') props(key,obj),
    jsonb_array_elements_text(defs.obj -> '@id') _id
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array'
    and defs.obj -> 'allOf' is null
union all
select
    concat(_id, '.', props.key) as id,
    props.key as property_id,
    case when props.obj ->> 'type' = 'array'
         then props.obj #>> '{items,$ref}'
         else props.obj ->> '$ref'
    end as definition_id,
    _id as class_id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    array[
        case when defs.obj -> 'required' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj ->> 'type' = 'array' then null else 1 end
    ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_array_elements(defs.obj -> 'allOf') _allOf,
    jsonb_each(_allOf #> '{properties}') props(key,obj),
    jsonb_array_elements_text(defs.obj -> '@id') _id
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array'
    and defs.obj -> 'allOf' is not null
union all
select
    concat(_id, '.', props.key) as id,
    props.key as property_id,
    case when props.obj #>> '{properties,type}' = 'array'
         then props.obj #>> '{properties,items,$ref}'
         else props.obj ->> '$ref'
    end as definition_id,
    _id as class_id,
    '3908e757-e482-4412-8759-ec6ef969482c' as class_model_id,
    array[
        case when _allOf #> '{then,required}' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj #>> '{properties,type}' = 'array' then null else 1 end
        ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_array_elements(defs.obj -> 'allOf') _allOf,
    jsonb_each(_allOf #> '{then,properties}') props(key,obj),
    jsonb_array_elements_text(defs.obj -> '@id') _id
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array'
    and defs.obj -> 'allOf' is not null;
alter view working.property__domain owner to edr_wheel;
grant select on table working.property__domain to edr_admin, edr_jwt, edr_edit, edr_read;