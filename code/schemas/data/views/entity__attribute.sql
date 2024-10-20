-- drop view if exists data.entity__attribute cascade;
create view data.entity__attribute as
    select
        id,
        entity_id,
        attribute_id,
        value,
        procedure__entity_id,
        agent_entity_id,
        time,
        quality
    from
        data.entity__measurement
    union
    select
        id,
        entity_id,
        attribute_id,
        value,
        procedure__entity_id,
        null as agent_entity_id,
        null as time,
        quality
    from
        data.entity__observation
    union
    select
        id,
        entity_id,
        attribute_id,
        value,
        null as procedure__entity_id,
        null as agent_entity_id,
        null as time,
        null as quality
    from
        data.entity__assertion;
alter view data.entity__attribute owner to edr_wheel;
grant insert, update, delete on table data.entity__attribute to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__attribute to edr_admin;
grant select on table data.entity__attribute to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view data.entity__attribute
	is 'Entity properties. UNION of `data.entity__assertion`, `data.entity__observation` and `data.entity__measurement`. INSERTS and UPDATES can be made against this view - data are directed to the appropriate union table using the instead of trigger tr_entity__attribute__upsert.';
comment on column data.entity__attribute.id
    is 'Entity attribute UUID';
comment on column data.entity__attribute.entity_id
    is 'Entity UUID';
comment on column data.entity__attribute.attribute_id
    is 'The attribute type - the key in a key-value-pair - from `cm.attribute`.';
comment on column data.entity__attribute.value
    is 'A JSON object holding the value of attribute. The data type for a given entity__attribute.type_id is defined in `cm.system__type__data_type.schema_json`.';
comment on column data.entity__attribute.time
    is 'The time the value was generated.';
comment on column data.entity__attribute.procedure__entity_id
    is 'A workflow, protocol, plan, algorithm, or computational method specifying how to make a observation or measurement.';
comment on column data.entity__attribute.agent_entity_id
    is 'The agent used to make the estimate.';
comment on column data.entity__attribute.quality
    is 'A JSON object holding a statistical quantification of uncertainty (e.g. a prediction interval). How uncertainty is expressed will vary as appropriate to the attribute, procedure and/or agent.';