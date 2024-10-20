-- drop function if exists cm.class__system__label__attribute(text,uuid) cascade;
create or replace function cm.class__system__label__attribute(
        _class_id text,
        _attribute_id uuid
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
                        id as class_id,
                        (
                            regexp_matches(system__label_template, '\{(.+?)\}', 'g')
                        )[1] as identifier
                    from
                        cm.class dc
                )
            select
                true into _result
            from
                _identifiers i
                    join cm.attribute da
                        on i.identifier = da.identifier
            where
                i.class_id = _class_id
                and da.id = _attribute_id;

            return coalesce(_result,false);

        end;

    $function$;
alter function cm.class__system__label__attribute(text,uuid) owner to edr_wheel;
grant execute on function cm.class__system__label__attribute(text,uuid) to edr_admin, edr_edit, edr_jwt;
comment on function cm.class__system__label__attribute(text,uuid)
    is 'Function that tests whether the attribute (`_attribute_id`) is part of the class''s label template.';