-- drop view if exists working.property__domain;
create or replace view working.property__domain as
select
    case when att.id ~ '^#'
        then concat('./', aj.file_name, att.id)
        else att.id
    end as attribute_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as class_id,
    array[
        case when defs.obj -> 'required' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj ->> 'type' = 'array' then null else 1 end
    ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_each(defs.obj #> '{properties}') props(key,obj),
    lateral (select case when props.obj ->> 'type' = 'array'
          then props.obj #>> '{items,$ref}'
          else props.obj ->> '$ref'
    end) att(id)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') != 'array'
    and att.id is not null
union all
select
    case when att.id ~ '^#'
        then concat('./', aj.file_name, att.id)
        else att.id
    end as attribute_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as class_id,
    array[
        case when defs.obj -> 'required' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj ->> 'type' = 'array' then null else 1 end
    ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_each(defs.obj #> '{properties}') props(key,obj),
    lateral (select case when props.obj ->> 'type' = 'array'
          then props.obj #>> '{items,$ref}'
          else props.obj ->> '$ref'
    end) att(id)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array'
    and defs.obj -> 'allOf' is null
    and att.id is not null
union all
select
    case when att.id ~ '^#'
        then concat('./', aj.file_name, att.id)
        else att.id
    end as attribute_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as class_id,
    array[
        case when defs.obj -> 'required' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj ->> 'type' = 'array' then null else 1 end
    ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_array_elements(defs.obj -> 'allOf') _allOf,
    jsonb_each(_allOf #> '{properties}') props(key,obj),
    lateral (select case when props.obj ->> 'type' = 'array'
          then props.obj #>> '{items,$ref}'
          else props.obj ->> '$ref'
    end) att(id)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array'
    and defs.obj -> 'allOf' is not null
    and att.id is not null
union all
select
    case when att.id ~ '^#'
        then concat('./', aj.file_name, att.id)
        else att.id
    end as attribute_id,
    concat('./', aj.file_name, '#/$defs/', defs.key) as class_id,
    array[
        case when _allOf #> '{then,required}' @> to_jsonb(props.key) then 1 else 0 end,
        case when props.obj #>> '{properties,type}' = 'array' then null else 1 end
        ] as constraint__multiplicity
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs}') defs(key,obj),
    jsonb_array_elements(defs.obj -> 'allOf') _allOf,
    jsonb_each(_allOf #> '{then,properties}') props(key,obj),
    lateral (select case when props.obj ->> 'type' = 'array'
          then props.obj #>> '{items,$ref}'
          else props.obj ->> '$ref'
    end) att(id)
where
    aj.file_name not in ('enum.json', 'geo.json', 'properties.json','properties-chemical.json','properties-physical.json')
    and defs.obj ->> 'type' = 'object'
    and jsonb_typeof(defs.obj -> '@id') = 'array'
    and defs.obj -> 'allOf' is not null
    and att.id is not null;
alter view working.property__domain owner to edr_wheel;
grant select on table working.property__domain to edr_admin, edr_jwt, edr_edit, edr_read;