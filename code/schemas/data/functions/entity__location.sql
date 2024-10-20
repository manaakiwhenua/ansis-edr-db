-- drop function if exists data.entity__location(uuid);
create or replace function data.entity__location(
        _entity_id uuid
    )
    returns geometry
    language plpgsql
    set search_path = cm, public
    as $function$

        declare
            _result text;

        begin

            select
                st_transform(
                    st_geomfromewkt(
                        ea.value ->> '.'
                    ),
                    4326
                ) into _result
            from
                data.entity__attribute ea
                    join data.entity e
                        on ea.entity_id = e.id
                    join cm.class c
                        on e.class_id = c.id
            where
                ea.entity_id = _entity_id
                and c.system__default_location_attribute_id = ea.attribute_id
            limit 1;

            return _result;

            exception
                when others then
                    raise notice E'Error building extent for entity %.\n-- SQL State: %\n-- SQL Error: %', _entity_id, sqlstate, sqlerrm;
                    return null::geometry;

        end;

    $function$;
alter function data.entity__location(uuid) owner to edr_wheel;
grant execute on function data.entity__location(uuid) to edr_admin, edr_jwt, edr_edit, edr_read;