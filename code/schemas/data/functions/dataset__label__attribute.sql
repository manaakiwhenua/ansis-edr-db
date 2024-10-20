-- drop function if exists data.dataset__label__attribute(uuid,text) cascade;
create or replace function data.dataset__label__attribute(
        _dataset_id uuid,
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
                        data.dataset c
                            left join cm.class cl
                                on c.class_id = cl.id
                            left join data.dataset__label_template clt
                                on c.class_id = clt.class_id
                                   and c.id = clt.dataset_id
                    where
                        c.id = _dataset_id
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
alter function data.dataset__label__attribute(uuid,text) owner to edr_wheel;
grant execute on function data.dataset__label__attribute(uuid,text) to edr_admin, edr_edit, edr_jwt;
comment on function data.dataset__label__attribute(uuid,text)
    is 'Function that tests whether the attribute (`_attribute_id`) is part of the dataset''s (`_dataset_id`) label template.';