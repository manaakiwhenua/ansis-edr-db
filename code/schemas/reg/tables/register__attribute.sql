
-- drop table if exists reg.register__attribute cascade;
create table reg.register__attribute (
	    id uuid default gen_random_uuid(),
	    register_id uuid not null,
	    attribute_id text not null,
	    value jsonb null,
	    constraint pk_register__attribute primary key (id),
	    constraint fk_register__attribute__register foreign key (register_id)
	        references reg.register (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_register__attribute__attribute foreign key (attribute_id)
            references cm.attribute (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index if not exists fx_register__attribute__register on reg.register__attribute(register_id);
create index if not exists fx_register__attribute__attribute on reg.register__attribute(attribute_id);
create index if not exists ix_register__attribute__value on reg.register__attribute using gin (value);
alter table	reg.register__attribute owner to edr_wheel;
grant insert, update, delete on table reg.register__attribute to edr_admin, edr_jwt, edr_edit;
grant truncate on table reg.register__attribute to edr_admin;
grant select on table reg.register__attribute to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table reg.register__attribute
	is 'Register properties stored as key (`attribute_id`) value pairs.';
comment on column reg.register__attribute.id
    is 'Register attribute UUID';
comment on column reg.register__attribute.register_id
    is 'Register UUID';
comment on column reg.register__attribute.attribute_id
    is 'The attribute type - the key in a key-value-pair - from `cm.attribute`.';
comment on column reg.register__attribute.value
    is 'A JSON object holding the value of attribute. The data type for a given `register__attribute.attribute_id` is defined in `cm.system__type__data_type.schema_json`.';