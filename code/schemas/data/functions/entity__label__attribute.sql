-- drop function if exists data.entity__label__attribute(uuid,text) cascade;
create or replace function data.entity__label__attribute(
        _entity_id uuid,
        _attribute_id text
    )
    returns bool
    language plpgsql
    set search_path = datastore, public
    as $function$

        declare
            _result bool;

        begin

            with _identifiers as (
                    select
                        (
                            regexp_matches(
                                coalesce(
                                    clt.system__label_template,
                                    cl.system__label_template
                                ),
                                '\{(.+?)\}',
                                'g'
                            )
                        )[1] as identifier
                    from
                        data.entity e
                            left join data.dataset c
                                on e.dataset_id = c.id
                            left join cm.class cl
                                on e.class_id = cl.id
                            left join data.dataset__label_template clt
                                on e.class_id = clt.class_id
                                   and c.id = clt.dataset_id
                    where
                        e.id = _entity_id
                )
            select
                true into _result
            from
                _identifiers i
                    join cm.attribute da
                        on i.identifier = da.identifier
            where
                da.id = _attribute_id;

            return coalesce(_result,false);

        end;

    $function$;
alter function data.entity__label__attribute(uuid,text) owner to edr_wheel;
grant execute on function data.entity__label__attribute(uuid,text) to edr_admin, edr_edit, edr_jwt;
comment on function data.entity__label__attribute(uuid,text)
    is 'Function that tests whether the attribute (`_attribute_id`) is part of the entity''s (`_entity_id`) label template.';