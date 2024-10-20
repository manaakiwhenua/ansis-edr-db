-- drop function if exists voc.concept__label();
create or replace function voc.concept__label(
        _concept_id text,                           -- id of the target concept
        _concept_collection_id uuid default null    -- the id of the concept collection template to be used. use the concept scheme template if null
    )
    returns text
    language plpgsql
    immutable
    set search_path = voc, public
    as $function$

        -- RETURNS: text (success)

        declare
            _default_template text; -- the default template as defined by the concept scheme
            _collection_template text; -- the concept collection specific template
            _response text; -- function response object

        begin

            select
                cs.system__label_template
            into
                _default_template
            from
                voc.concept_scheme cs
                    join voc.concept c on cs.id = c.concept_scheme_id
            where
                c.id = _concept_id;

            if
                _concept_collection_id is not null
            then
                select
                    cc.system__label_template
                into
                    _collection_template
                from
                    voc.concept_collection cc
                where
                    cc.id = _concept_collection_id;
            end if;

            select
                replace(
                    replace(
                        coalesce(_collection_template, _default_template), '${preferred_label}', c.preferred_label
                    ), '${notation}', c.notation
                )
            into
                _response
            from
                voc.concept c
            where
                c.id = _concept_id;

            return _response;

        end

    $function$;
alter function voc.concept__label(text,uuid) owner to edr_wheel;
grant execute on function voc.concept__label(text,uuid) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function voc.concept__label(text,uuid)
    is 'Returns a concept''s (`_concept_id`) formatted label based on the concept collection (`_concept_collection_id`) or concept scheme (if `_concept_collection_id` is null) template defined in `concept_collection`|`concept_scheme.system__label_template`.';