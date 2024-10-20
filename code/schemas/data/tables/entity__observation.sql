-- drop table if exists data.entity__observation cascade;
create table data.entity__observation (
	    id uuid default gen_random_uuid(),
	    entity_id uuid not null,
	    attribute_id text not null,
	    value jsonb not null,
	    procedure__entity_id uuid null,
	    quality jsonb null,
	    constraint pk_entity__observation primary key (id),
	    constraint fk_entity__observation__entity foreign key (entity_id)
	        references data.entity (id)
	        on delete cascade on update cascade
	        deferrable initially deferred/*,
	    constraint fk_entity__observation__attribute foreign key (attribute_id)
	        references cm.attribute (id)
	        on delete restrict on update cascade
	        deferrable initially deferred*/
	);
create index if not exists fx_entity__observation__entity on data.entity__observation(entity_id);
create index if not exists fx_entity__observation__attribute on data.entity__observation(attribute_id);
create index if not exists ix_entity__observation__value on data.entity__observation using gin (value);
alter table	data.entity__observation owner to edr_wheel;
grant insert, update, delete on table data.entity__observation to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__observation to edr_admin;
grant select on table data.entity__observation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity__observation
	is 'Observed entity properties stored as key (`attribute_id`) value pairs. Observations capture characteristics of an entity that are estimated using some sort of procedure, with a corresponding quality. As a general rule observations are made on-site, i.e. where the entity occurs naturally, by humans while sampling.';
comment on column data.entity__observation.id
    is 'Entity attribute UUID';
comment on column data.entity__observation.entity_id
    is 'Entity UUID';
comment on column data.entity__observation.attribute_id
    is 'The attribute type - the key in a key-value-pair - from `cm.attribute`.';
comment on column data.entity__observation.value
    is 'A JSON object holding the value of attribute. The data type for a given `entity__observation.attribute_id` is defined in `cm.system__type__data_type.schema_json`.';
comment on column data.entity__observation.procedure__entity_id
    is 'A workflow, protocol, plan, algorithm, or computational method specifying how to make an Observation.';
comment on column data.entity__observation.quality
    is 'A JSON object holding a statistical quantification of uncertainty (e.g. a prediction interval). How uncertainty is expressed will vary as appropriate to the attribute, procedure and/or sensor.';