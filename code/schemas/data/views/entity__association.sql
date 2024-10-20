-- drop view if exists data.entity__association cascade;
create view data.entity__association as
    select
        id,
        association_id,
        entity_id,
        associated_entity_id,
        system__order
    from
        data.entity__relationship
    union
    select
        id,
        association_id,
        entity_id,
        associated_entity_id,
        system__order
    from
        data.entity__aggregation;
alter view data.entity__association owner to edr_wheel;
grant insert, update, delete on table data.entity__association to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__association to edr_admin;
grant select on table data.entity__association to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view data.entity__association
	is 'Associations that link entities with other entities. UNION of `data.entity__relationship` and `data.entity__aggregation`. INSERTS and UPDATES can be made against this view - data are directed to the appropriate union table using the instead of trigger tr_entity__association__upsert.';
comment on column data.entity__association.id
    is 'Entity association UUID.';
comment on column data.entity__association.association_id
    is 'The association type - the key in a key-value-pair - from `cm.association`.';
comment on column data.entity__association.entity_id
    is 'The entity UUID.';
comment on column data.entity__association.associated_entity_id
    is 'The associated entity UUID.';
comment on column data.entity__association.system__order
    is 'The order the entity''s associated entities are to be returned in an array or user interface.';