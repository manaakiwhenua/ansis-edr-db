-- drop function if exists auth.operator__jwt() cascade;
create or replace function auth.operator__jwt()
    returns uuid
    language plpgsql
    volatile
    security definer
as
$func$
    declare
        _operator__jwt uuid;

    begin

        _operator__jwt :=
            nullif(
                current_setting('request.jwt', true),
                ''
            )::jsonb ->> 'sub';

        _operator__jwt :=
            coalesce(
                _operator__jwt,
                '5a4031c0-2136-411f-a80f-960e14a6d68e' -- anonymous operator
            );

        return _operator__jwt;

    end;

$func$;
alter function auth.operator__jwt() owner to edr_wheel;
grant execute on function auth.operator__jwt() to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function auth.operator__jwt()
    is 'Returns the operatorUuid value extracted from a JWT captured in the setting `request.jwt.claims`. Assumes the client, or a DB function supporting the client, has set this value using `set_config(''request.jwt.claims'',...)` when accessing the database. If not, the id of the database''s anonymous user is returned.';