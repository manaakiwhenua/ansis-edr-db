-- drop function if exists sys.array_remove_overlap(anyarray) cascade;
create or replace function sys.array_remove_overlap(
        _target_array anyarray,
        _comparison_array anyarray
    )
    returns anyarray
    language plpgsql
    volatile
    security definer
as
$func$
    declare
        _result text;

    begin

        select
            array_agg(ta.element) into _result
        from
            unnest(_target_array) as ta(element)
        where
            not exists(
                select
                    0
                from
                    unnest(_comparison_array) as ca(element)
                where
                    ca.element = ta.element
            );

        return _result;

    end;

$func$;
alter function sys.array_remove_overlap(anyarray,anyarray) owner to edr_wheel;
grant execute on function sys.array_remove_overlap(anyarray,anyarray) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function sys.array_remove_overlap(anyarray,anyarray)
    is 'Returns any overlapping elements in the comparison array from the target array.';