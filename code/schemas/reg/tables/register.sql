-- drop table if exists reg.register cascade;
create table
	reg.register (
	    id uuid default gen_random_uuid() not null,
	    default_label text null,
	    register_id uuid null,
	    constraint pk_register primary key (id),
	    constraint fk_register__register foreign key (register_id)
	        references reg.register (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index fx_register__register on reg.register(register_id);
create index ix_register__default_label on reg.register using gin (default_label gin_trgm_ops);
alter table reg.register owner to edr_wheel;
grant insert, update, delete on table reg.register to edr_admin, edr_jwt, edr_edit;
grant truncate on table reg.register to edr_admin;
grant select on table reg.register to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table reg.register
    is 'Registers of resources (e.g. concept schemes, concept and attribute collections, entity datasets, or entities). Registers document the governance of, and manage access to, resources.';
comment on column reg.register.id
    is 'Register UUID.';
comment on column reg.register.default_label
    is 'The default label for a register when displayed. Derived by concatenating one or more attribute values in `reg.register__attribute` and populated by a trigger function on that table.';
comment on column reg.register.register_id
    is 'Parent register UUID. Organisation of registers into hierarchies should be discouraged in favour of organisation into registers (`reg.register`).';