-- drop function if exists auth.operator__register_access(uuid,auth_access) cascade;
create or replace function auth.operator__register_access(
        _register_id uuid,
        _claimed_access auth_access
    )
    returns int
    language plpgsql
    volatile
    security definer
as
$func$
    declare
        _operator__jwt uuid;
        _result int;

    begin

        _operator__jwt = auth.operator__jwt();

        select
            case when _claimed_access = 'read'
                 then case when _operator__jwt = any(register_read)
                           then 200
                           else 403
                      end
                 when _claimed_access = 'edit'
                 then case when _operator__jwt = any(register_edit)
                           then 200
                           else 403
                      end
                 when _claimed_access = 'admin'
                 then case when _operator__jwt = any(register_admin)
                           then 200
                           else 403
                      end
            end into _result
        from
            auth.aggregated__authorisation
        where
            register_id = _register_id;

        if _result = 403 and _operator__jwt = '5a4031c0-2136-411f-a80f-960e14a6d68e' then
            _result := 401;
        end if;

        _result := coalesce(_result,404);

        return _result;

    end;

$func$;
alter function auth.operator__register_access(uuid,auth_access) owner to edr_wheel;
grant execute on function auth.operator__register_access(uuid,auth_access) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function auth.operator__register_access(uuid,auth_access)
    is 'Checks if the operator identified by the current JWT in the `request.jwt.claims` system setting has the claimed access rights (`_claimed_access`) against the specified register (`_register_id`). If the claimed rights have been granted to the anonymous user (5a4031c0-2136-411f-a80f-960e14a6d68e) then the input user will have those rights. Returns an HTTP status code: 200, access is `ok`; 403, access is `forbidden` to an authorised user (JWT exists); 401, access forbidden to an `unauthorised` user (anonymous/no JWT); 404, the specified register was `not found`.';