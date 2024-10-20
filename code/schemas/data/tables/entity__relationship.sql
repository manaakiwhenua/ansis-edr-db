-- drop table if exists data.entity__relationship cascade;
create table data.entity__relationship (
        id uuid default gen_random_uuid(),
	    association_id text not null,
	    entity_id uuid not null,
	    associated_entity_id uuid not null,
	    system__order integer null,
	    constraint pk_entity__relationship primary key (id),
	    constraint uq_entity__relationship__entities unique (association_id, entity_id, associated_entity_id)
            deferrable initially deferred,
	    constraint fk_entity__relationship__entity foreign key (entity_id)
	        references data.entity (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_entity__relationship__associated_entity foreign key (associated_entity_id)
            references data.entity (id)
            on delete cascade on update cascade
            deferrable initially deferred/*,
        constraint fk_entity__relationship__association foreign key (association_id)
            references cm.association (id)
            on delete restrict on update cascade
            deferrable initially deferred*/
	);
create index if not exists fx_entity__relationship__entity on data.entity__relationship(entity_id);
create index if not exists fx_entity__relationship__associated_entity on data.entity__relationship(associated_entity_id);
create index if not exists fx_entity__relationship__association	on data.entity__relationship(association_id);
alter table data.entity__relationship owner to edr_wheel;
grant insert, update, delete on table data.entity__relationship to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity__relationship to edr_admin;
grant select on table data.entity__relationship to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity__relationship
	is 'Relationships link independent entities to each other..';
comment on column data.entity__relationship.id
    is 'Entity relationship UUID.';
comment on column data.entity__relationship.association_id
    is 'The association type - the key in a key-value-pair - from `cm.association`.';
comment on column data.entity__relationship.entity_id
    is 'The entity UUID.';
comment on column data.entity__relationship.associated_entity_id
    is 'The associated entity UUID.';
comment on column data.entity__relationship.system__order
    is 'The order the associated entities are to be returned in an array or user interface.';