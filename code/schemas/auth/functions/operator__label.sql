-- drop function if exists auth.operator__label(uuid) cascade;
create or replace function auth.operator__label(
        _operator_id uuid
    )
    returns text
    language plpgsql
    volatile
    security definer
as
$func$
    declare
        _result text;

    begin

        select
            label into _result
        from
            auth.operator
        where
            id = _operator_id;

        return _result;

    end;

$func$;
alter function auth.operator__label(uuid) owner to edr_wheel;
grant execute on function auth.operator__label(uuid) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function auth.operator__label(uuid)
    is 'Returns the label for the operator (`_operator_id`).';