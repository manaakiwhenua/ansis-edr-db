-- drop table if exists data.entity cascade;
create table data.entity (
        id uuid default gen_random_uuid() not null,
        dataset_id uuid not null,
        class_id text not null,
        default_label text null,
        constraint pk_entity primary key (id),
        -- constraint fk_entity__class foreign key (class_id)
        --     references cm.class (id)
        --     on delete restrict on update cascade
        --     deferrable initially deferred,
	    constraint fk_entity__dataset foreign key (dataset_id)
	        references data.dataset (id)
	        on delete restrict on update cascade
	        deferrable initially deferred
    );
create index if not exists fx_entity__class on data.entity(class_id);
create index if not exists fx_entity__dataset on data.entity(dataset_id);
create index if not exists ix_entity__default_label on data.entity using gin (default_label gin_trgm_ops);
alter table	data.entity owner to edr_wheel;
grant insert, update, delete on table data.entity to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.entity to edr_admin;
grant select on table data.entity to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity
    is 'Entities are instances of classes that describe environmental or sampling entities, and their parts. Entities must be organised and managed in a dataset.';
comment on column data.entity.id
    is 'Entity UUID.';
comment on column data.entity.dataset_id
    is 'Links an entity to its dataset. Used by Row Level Security policies (where present).';
comment on column data.entity.class_id
    is 'The type of entity as defined in `cm.class`.';
comment on column data.entity.default_label
    is 'The default label for an entity when displayed. Derived by concatenating one or more attribute values in `data.entity__assertion|attribute|measurement` and populated by a trigger function on that table.';