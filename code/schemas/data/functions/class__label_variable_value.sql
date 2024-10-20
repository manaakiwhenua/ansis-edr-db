-- drop function if exists data.class__label_variable_value(text,text,text);
create or replace function data.class__label_variable_value(
        _attribute_table_prefix text,   -- the prefix of the attribute table (dataset or entity)
        _class_id text,                 -- id of the target entity
        _variable_identifier text       -- the system__label_template variable attribute identifier
    )
    returns text
    language plpgsql
    set search_path = cm, public
    as $function$

    declare
        _attribute_id text;
        _select_expression text;
        _values text[];
        _value_index int;
        _result text;

    begin

        select
            a.id,
            coalesce(
                case
                    when dt.schema_json ->> 'type' = 'object'
                        then replace(dt.pgsql_select_expression #>> '{.,asText}', '${alias}', 'att.')
                    else replace(dt.pgsql_select_expression ->> '.', '${alias}', 'att.')
                end,
                ''
            )
        into _attribute_id, _select_expression
        from
            cm.attribute a
                join cm.system__type__data_type dt
                    on a.data_type_id = dt.id
        where
            a.identifier = regexp_replace(split_part(_variable_identifier,'[', 1),'^\$\{(.*)\}', '\1');

        execute
            format(
                $fmt$
                    select
                        array_agg(
                            distinct
                            (%1$s)::text
                        ) as _result
                    from
                        data.%2$s__attribute att
                    where
                        att.%2$s_id = %3$L
                        and att.attribute_id = %4$L
                    group by
                        att.%2$s_id
                $fmt$,
                _select_expression,
                _attribute_table_prefix,
                _class_id,
                _attribute_id
            )
            into _values;

        _value_index :=
            (
                regexp_match(
                    _variable_identifier,
                    '\[(.+?)\]'
                )
            )[1];

        _result :=
            case when _value_index is not null
                 then _values[least(_value_index,array_length(_values,1))]
                 else array_to_string(_values, '; ')
            end;

        return _result;

    end;

    $function$;
alter function data.class__label_variable_value(text,text,text) owner to edr_wheel;
grant execute on function data.class__label_variable_value(text,text,text) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function data.class__label_variable_value(text,text,text)
    is 'Returns the value for an attribute of a dataset or entity (class) based on a variable in the label template. If multiple values are found, the result is concatenated into delimited string, unless an index is provided with the variable (e.g. ${variable}[1]) in which case the value at the position (or closest to it) is provided.';