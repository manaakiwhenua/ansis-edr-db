-- drop view if exists working.association;
-- create or replace view working.association as
-- with _association as (
--         select
-- --             case when jsonb_typeof(defs.obj -> '@id') = 'array'
-- --                  then concat(array_to_string(replace(replace(replace((defs.obj ->> '@id'),'"', ''), '[', '{'), ']', '}')::text[], '.'),'.',coalesce(wca.id,wcr.id))
-- --                  else concat(defs.obj ->> '@id','.', wp.class_id)
-- --             end as id,
--             concat('./', aj.file_name, '#/$defs/_rel/$defs/', defs.key) as id,
--             '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
-- --             wp.class_id as source_class_id,
-- --             coalesce(wca.id,wcr.id) as target_class_id,
--             defs.key as identifier,
--             lower(coalesce(defs.obj ->> 'title', defs.key)) as label,
--             null::boolean as bidirectional,
--             null as inverse_identifier,
--             null as inverse_label,
-- --             wp.constraint__multiplicity,
--             defs.obj ->> 'description' as definition,
--             defs.obj ->> '$comment' as editorial_note,
--             null::text[] as rdf_match,
--             null::text[] as see_also,
--             null::jsonb as constraints,
--             case when defs.obj ->> '$ref' = './base.json#/$defs/pointer'
--                  then 'edr-entity-relationship'
--                  else 'edr-entity-aggregation'
--             end as system__type_id
--         from
--             working.ansis_json aj,
--             jsonb_each(aj.file #> '{$defs, _rel, $defs}') defs(key,obj)
--         where
--             aj.file_name = 'properties.json'
--     )
select
    concat('./', aj.file_name, '#/$defs/_rel/$defs/', defs.key) as id,
    '3908e757-e482-4412-8759-ec6ef969482c'::uuid as class_model_id,
    array_agg(wp.class_id) as source_class_id,
    array_agg(coalesce(wca.id,wcr.id)) as target_class_id,
    defs.key as identifier,
    lower(coalesce(defs.obj ->> 'title', defs.key)) as label,
    null::boolean as bidirectional,
    null as inverse_identifier,
    null as inverse_label,
    any_value(wp.constraint__multiplicity) as constraint__multiplicity,
    defs.obj ->> 'description' as definition,
    defs.obj ->> '$comment' as editorial_note,
    null::text[] as rdf_match,
    null::text[] as see_also,
    null::jsonb as constraints,
    case when defs.obj ->> '$ref' = './base.json#/$defs/pointer'
         then 'edr-entity-relationship'
         else 'edr-entity-aggregation'
    end as system__type_id
from
    working.ansis_json aj,
    jsonb_each(aj.file #> '{$defs, _rel, $defs}') defs(key,obj)
        left join working.property__domain wp on concat('./properties.json#/$defs/_rel/$defs/', defs.key) = wp.definition_id
        left join working.class wca on defs.obj ->> '$ref' = wca.id
        left join working.class wcr on defs.obj ->> '_refType' = wcr.id
where
    aj.file_name = 'properties.json'
group by
    aj.file_name,
    defs.key,
    defs.obj;
alter view working.association owner to edr_wheel;
grant select on table working.association to edr_admin, edr_jwt, edr_edit, edr_read;