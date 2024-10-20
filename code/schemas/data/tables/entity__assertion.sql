-- drop table if exists data.entity__assertion cascade;
create table data.entity__assertion (
	    id uuid default gen_random_uuid(),
	    entity_id uuid not null,
	    attribute_id text not null,
	    value jsonb not null,
	    constraint pk_entity__assertion primary key (id),
	    constraint fk_entity__assertion__entity foreign key (entity_id)
	        references data.entity (id)
	        on delete cascade on update cascade
	        deferrable initially deferred/*,
	    constraint fk_entity__assertion__attribute foreign key (attribute_id)
	        references cm.attribute (id)
	        on delete restrict on update cascade
	        deferrable initially deferred*/
	);
create index if not exists fx_entity__assertion__entity on data.entity__assertion(entity_id);
create index if not exists fx_entity__assertion__attribute on data.entity__assertion(attribute_id);
create index if not exists ix_entity__assertion__value on data.entity__assertion using gin (value);
alter table	data.entity__assertion owner to edr_wheel;
grant insert, update, delete on table data.entity__assertion to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__assertion to edr_admin;
grant select on table data.entity__assertion to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity__assertion
	is 'Asserted entity properties stored as key (`attribute_id`) value pairs.';
comment on column data.entity__assertion.id
    is 'Entity attribute UUID';
comment on column data.entity__assertion.entity_id
    is 'Entity UUID';
comment on column data.entity__assertion.attribute_id
    is 'The attribute type - the key in a key-value-pair - from `cm.attribute`.';
comment on column data.entity__assertion.value
    is 'A JSON object holding the value of attribute. The data type for a given `entity__assertion.attribute_id` is defined in `cm.system__type__data_type.schema_json`.';