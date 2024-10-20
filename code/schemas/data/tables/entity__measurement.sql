-- drop table if exists data.entity__measurement cascade;
create table data.entity__measurement (
	    id uuid default gen_random_uuid(),
	    entity_id uuid not null,
	    attribute_id text not null,
	    value jsonb not null,
	    procedure__entity_id uuid not null,
	    agent_entity_id uuid null,
	    time timestamptz null,
	    quality jsonb null,
	    constraint pk_entity__measurement primary key (id),
	    constraint fk_entity__measurement__entity foreign key (entity_id)
	        references data.entity (id)
	        on delete cascade on update cascade
	        deferrable initially deferred/*,
	    constraint fk_entity__measurement__attribute foreign key (attribute_id)
	        references cm.attribute (id)
	        on delete restrict on update cascade
	        deferrable initially deferred*/
	);
create index if not exists fx_entity__measurement__entity on data.entity__measurement(entity_id);
create index if not exists fx_entity__measurement__attribute on data.entity__measurement(attribute_id);
create index if not exists ix_entity__measurement__value on data.entity__measurement using gin (value);
alter table data.entity__measurement owner to edr_wheel;
grant insert, update, delete on table data.entity__measurement to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__measurement to edr_admin;
grant select on table data.entity__measurement to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity__measurement
	is 'Measured entity properties stored as key (`attribute_id`) value pairs. Measurements are created when detailed metadata describing the procedure and equipment used to make the estimate, when it was made, and its uncertainty is required. Measurements are typically made off-site, using some sort of sensor or software agent.';
comment on column data.entity__measurement.id
    is 'Entity Measurement UUID';
comment on column data.entity__measurement.entity_id
    is 'Entity UUID';
comment on column data.entity__measurement.attribute_id
    is 'The attribute type - the key in a key-value-pair - from `cm.attribute`.';
comment on column data.entity__measurement.value
    is 'A JSON object holding the value of attribute. The data type for a given entity__measurement.type_id is defined in `cm.system__type__data_type.schema_json`.';
comment on column data.entity__measurement.time
    is 'The time the value was generated.';
comment on column data.entity__measurement.procedure__entity_id
    is 'A workflow, protocol, plan, algorithm, or computational method specifying how to make a Measurement.';
comment on column data.entity__measurement.agent_entity_id
    is 'The agent used to make the estimate.';
comment on column data.entity__measurement.quality
    is 'A JSON object holding a statistical quantification of uncertainty (e.g. a prediction interval). How uncertainty is expressed will vary as appropriate to the attribute, procedure and/or agent.';