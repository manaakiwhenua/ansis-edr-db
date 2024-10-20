-- drop function if exists data.entity__location__attribute(uuid,text) cascade;
create or replace function data.entity__location__attribute(
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

            select
                true into _result
            from
                data.entity e
                    join cm.class c
                        on e.class_id = c.id
            where
                e.id = _entity_id
                and c.system__default_location_attribute_id = _attribute_id;

            return coalesce(_result,false);

        end;

    $function$;
alter function data.entity__location__attribute(uuid,text) owner to edr_wheel;
grant execute on function data.entity__location__attribute(uuid,text) to edr_admin, edr_edit, edr_jwt;
comment on function data.entity__location__attribute(uuid,text)
    is 'Function that tests whether the attribute (`_attribute_id`) is the entity''s (`_entity_id`) location attribute.';