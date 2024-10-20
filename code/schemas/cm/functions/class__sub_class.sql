-- drop function if exists cm.class__sub_class() cascade;
create or replace function cm.class__sub_class(
        _class_id text  -- id of the class type
    )
    returns text[]
    language plpgsql
    set search_path = def, public
    as $function$

        -- RETURNS: text[] (success)

        declare
            _response text[]; -- function response object

        begin

            with recursive _sub_types as (
                    select
                        cs.sub_class_id
                    from
                        cm.class__specialisation cs
                    where
                        cs.class_id = _class_id
                    union all
                    select
                        cs.sub_class_id
                    from
                        _sub_types st
                            join cm.class__specialisation cs on st.sub_class_id = cs.class_id
                )
            select
                array_agg(sub_class_id)
                into _response
            from
                _sub_types;

            return _response;

        end

    $function$;
alter function cm.class__sub_class(text) owner to edr_wheel;
grant execute on function cm.class__sub_class(text) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function cm.class__sub_class(text)
    is 'Returns an array of ids of the class''s (`_class_id`) sub-classes.';