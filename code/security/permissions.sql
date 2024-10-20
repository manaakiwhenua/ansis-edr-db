-- manage DB access
alter database
    edr
owner to
    edr_wheel;

grant
    connect, temporary
on database
    edr
to
    edr_admin,
    edr_jwt,
    edr_edit,
    edr_read;

revoke
   connect, temporary
on database
    edr
from
    public;

-- manage schema usage
grant
    usage
on schema
    auth,
    data,
    cm,
    public,
    reg,
    sys,
    voc,
    working
to
    edr_admin,
    edr_jwt,
    edr_edit,
    edr_read;