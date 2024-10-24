-- drop table if exists data.dataset cascade;
create table
	data.dataset (
	    id uuid default gen_random_uuid() not null,
        register_id uuid default 'a7187fec-1098-4c4d-a2bf-9d5544deeaa2'::uuid not null,
	    class_model_id uuid null,
	    class_id text null,
	    default_label text null,
	    dataset_id uuid null,
	    constraint pk_dataset primary key (id),
	    -- constraint fk_dataset_register foreign key (register_id)
	    --    references reg.register (id)
        --    on delete restrict on update cascade
        --    deferrable initially deferred,
	    -- constraint fk_dataset__class_model foreign key (class_model_id)
	    --     references cm.class_model (id)
        --     on delete restrict on update cascade
        --     deferrable initially deferred,
	    -- constraint fk_dataset__class foreign key (class_id)
	    --     references cm.class (id)
        --     on delete restrict on update cascade
        --     deferrable initially deferred,
	    constraint fk_dataset__dataset foreign key (dataset_id)
	        references data.dataset (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index fx_dataset__register on data.dataset(register_id);
create index fx_dataset__class on data.dataset(class_id);
create index fx_dataset__dataset on data.dataset(dataset_id);
create index ix_dataset__default_label on data.dataset using gin (default_label gin_trgm_ops);
alter table data.dataset owner to edr_wheel;
grant insert, update, delete on table data.dataset to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.dataset to edr_admin;
grant select on table data.dataset to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.dataset
	is 'Datasets (collections) organise entities into logical collections with a common purpose, e.g. a soil survey, and owner. Containers ''own'' the entities and, as such, are the primary location in which an entity is managed. Deleting a dataset deletes all member entities.';
comment on column data.dataset.id
    is 'Dataset UUID.';
comment on column data.dataset.register_id
    is 'The register the governs dataset licensing, and access constraints.';
comment on column data.dataset.class_model_id
    is 'The class model that governs the types of entities, properties and associations in the dataset.';
comment on column data.dataset.class_id
    is 'The type of dataset as defined in `cm.class`.';
comment on column data.dataset.default_label
    is 'The default label for a dataset when displayed. Derived by concatenating one or more attribute values in `data.dataset__attribute` and populated by a trigger function on that table.';
comment on column data.dataset.dataset_id
    is 'Parent dataset UUID. Organisation of datasets into hierarchies should be discouraged in favour of organisation into registers (`reg.register`).';