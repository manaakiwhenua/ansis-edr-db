-- drop view if exists working.concept_scheme;
create or replace view working.concept_scheme as
    with _curiPrefix as (
        select
            defs.key as prefix,
            defs.val as uri
        from
            working.ansis_json aj,
            jsonb_each_text(aj.file -> '_curiPrefix') defs(key,val)
        where
            aj.file_name = 'enum.json'
    )
    select
        defs.key as id,
        'e3f68055-82bf-4e3d-a30c-3bf3eaf4eb1d'::uuid as register_id,
        defs.obj ->> 'title' as preferred_label,
        defs.key as notation,
        defs.obj ->> 'description' as description,
        defs.obj ->> '$comment' as editorial_note,
        array[
            case when cp.uri is null
                 then defs.obj ->> '@id'
                 else concat(cp.uri,split_part(defs.obj ->> '@id',':',2))
            end
        ] as source,
        case when cp.uri ~ 'anzsoil.org'
             then array['https://github.com/ANZSoilData/']
        end as see_also,
        'en' as system__language,
        '${preferred_label}' as system__label_template,
        null::text[] as system__tag
    from
        working.ansis_json aj,
        jsonb_each(aj.file -> '$defs') defs(key,obj)
            left join _curiPrefix cp
                on split_part(defs.obj ->> '@id',':',1) = cp.prefix
    where
        aj.file_name = 'enum.json';
alter view working.concept_scheme owner to edr_wheel;
grant select on table working.concept_scheme to edr_admin, edr_jwt, edr_edit, edr_read;