-- drop table if exists auth.operator cascade;
create table auth.operator(
        id uuid not null,
        domain text default 'ansis' not null,
        label text not null,
        active bool default true not null,
	    constraint pk_operator primary key (id)
    );
alter table auth.operator owner to edr_wheel;
grant select on table auth.operator to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table auth.operator
    is 'Operators - row level security users as authenticated by an authentication service - permitted access to the EDR. The default service is MWLR''s authentication service.';
comment on column auth.operator.id
    is 'The Operator UUID as allocated by the authentication service.';
comment on column auth.operator.domain
    is 'The domain/authentication service that allocated the ID.';
comment on column auth.operator.label
    is 'The display label, typically the operator''s name, for the operator.';
comment on column auth.operator.active
    is 'Marks whether the user is active or not. Inactive operators may not interact with the database and will therefore by ignored for row level security approval.';

-- initialise table
insert into auth.operator (
	id,
    domain,
	label,
	active
)
values
	('5a4031c0-2136-411f-a80f-960e14a6d68e', 'ansis', 'Anonymous User', true)
on conflict (id) do update
    set
        domain = excluded.domain,
        label = excluded.label,
        active = excluded.active;