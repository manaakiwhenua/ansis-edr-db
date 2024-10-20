-- drop function if exists cm.validate_attribute_value cascade;
create or replace function cm.validate_attribute_value(
        _attribute_id text,
        _value jsonb
    )
    returns bool
    language plpgsql
    immutable
    as $function$

        declare
            _result bool;

        begin

            select
                case when cm.validate_json_object ( _value -> '.', dt.schema_json) ->> 'status' = 'pass'
                     then true
                     else false
                end into _result
            from
                cm.attribute att
                    join cm.system_type__data_type dt
                        on att.data_type_id = dt.id
            where
                att.id = _attribute_id;

            return _result;

        end;

    $function$;
alter function cm.validate_attribute_value owner to edr_wheel;
grant execute on function cm.validate_attribute_value to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function cm.validate_attribute_value
    is 'Validates a entity`s attribute (`_id`) value according to its attribute''s (`_attribute_id`) data type.';