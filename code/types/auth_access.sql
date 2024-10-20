-- drop type if exists auth_access;
create type auth_access as
    enum (
        'admin',
        'edit',
        'read',
        'deny'
    );
comment on type auth_access is 'Specified row level security access rights that can be granted to a user on a container (dataset or register).';