-- drop table if exists data.entity__aggregation cascade;
create table data.entity__aggregation (
        id uuid default gen_random_uuid(),
	    association_id text not null,
	    entity_id uuid not null,
	    associated_entity_id uuid not null,
	    system__order integer null,
	    constraint pk_entity__aggregation primary key (id),
	    constraint fk_entity__aggregation__entity foreign key (entity_id)
	        references data.entity (id)
            on delete restrict on update cascade
            deferrable initially deferred,
        constraint fk_entity__aggregation__associated_entity foreign key (associated_entity_id)
            references data.entity (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        -- constraint fk_entity__aggregation__association foreign key (association_id)
        --     references cm.association (id)
        --     on delete restrict on update cascade
        --     deferrable initially deferred,
	    constraint uq_entity__aggregation__associated_entity unique (associated_entity_id)
            deferrable initially deferred,
        constraint ck_entity__aggregation__recursion check (
	        not(
	            associated_entity_id = any(data.entity__aggregates(entity_id))
	        )
        )
	);
create index if not exists fx_entity__aggregation__entity on data.entity__aggregation(entity_id);
create index if not exists fx_entity__aggregation__association on data.entity__aggregation(association_id);
alter table	data.entity__aggregation owner to edr_wheel;
grant insert, update, delete on table data.entity__aggregation to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__aggregation to edr_admin;
grant select on table data.entity__aggregation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity__aggregation
	is 'A specialised association that combines entities into into aggregates - those that are made up of other entities. If an aggregate entity is deleted, its parts are also deleted (by trigger function `data.tf_entity__aggregation__delete()`).';
comment on column data.entity__aggregation.id
    is 'Entity aggregation UUID.';
comment on column data.entity__aggregation.association_id
    is 'The association type - the key in a key-value-pair - from `cm.association`.';
comment on column data.entity__aggregation.entity_id
    is 'The aggregate entity UUID.';
comment on column data.entity__aggregation.associated_entity_id
    is 'The associated entity UUID.';
comment on column data.entity__aggregation.system__order
    is 'The order the entity''s parts are to be returned in an array or user interface.';
comment on constraint uq_entity__aggregation__associated_entity on data.entity__aggregation
    is 'Ensures that the associated_entity_id is unique as an entity can only be a part of one aggregate.';
comment on constraint ck_entity__aggregation__recursion on data.entity__aggregation
    is 'Ensures that the associated entity is not already present in the aggregate ''tree''.';