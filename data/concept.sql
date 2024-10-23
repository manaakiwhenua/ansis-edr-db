-- drop view if exists working.concept;
create or replace view working.concept as
    select
        const ->> 'const' as id,
        defs.obj ->> '@id' as concept_scheme_id,
        true as top_concept,
        const ->> 'description' as preferred_label,
        null as alternative_labels,
        case when notation != const ->> 'const' and
                  notation != const ->> 'description'
             then notation
        end as notation,
        null as definition,
        null as editorial_note,
        'en' as system__language,
        null as system__order
    from
        working.ansis_json aj,
        jsonb_each(aj.file -> '$defs') defs(key,obj),
        jsonb_array_elements(defs.obj -> 'oneOf') const,
        reverse(split_part(reverse(const ->> 'const'),'-',1)) as notation
    where
        aj.file_name = 'enum.json'
        and defs.obj ->> '@id' is not null;
alter view working.concept owner to edr_wheel;
grant select on table working.concept to edr_admin, edr_jwt, edr_edit, edr_read;