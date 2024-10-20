-- drop table if exists data.dataset__attribute cascade;
create table data.dataset__attribute (
	    id uuid default gen_random_uuid(),
	    dataset_id uuid not null,
	    attribute_id text not null,
	    value jsonb null,
	    constraint pk_dataset__attribute primary key (id),
	    constraint fk_dataset__attribute__dataset foreign key (dataset_id)
	        references data.dataset (id)
            on delete cascade on update cascade
            deferrable initially deferred/*,
        constraint fk_dataset__attribute__attribute foreign key (attribute_id)
            references cm.attribute (id)
            on delete restrict on update cascade
            deferrable initially deferred*/
	);
create index if not exists fx_dataset__attribute__dataset on data.dataset__attribute(dataset_id);
create index if not exists fx_dataset__attribute__attribute on data.dataset__attribute(attribute_id);
create index if not exists ix_dataset__attribute__value on data.dataset__attribute using gin (value);
alter table	data.dataset__attribute owner to edr_wheel;
grant insert, update, delete on table data.dataset__attribute to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.dataset__attribute to edr_admin;
grant select on table data.dataset__attribute to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.dataset__attribute
	is 'Dataset properties stored as key (`attribute_id`) value pairs.';
comment on column data.dataset__attribute.id
    is 'Dataset attribute UUID';
comment on column data.dataset__attribute.dataset_id
    is 'Dataset UUID';
comment on column data.dataset__attribute.attribute_id
    is 'The attribute type - the key in a key-value-pair - from `cm.attribute`.';
comment on column data.dataset__attribute.value
    is 'A JSON object holding the value of attribute. The data type for a given `dataset__attribute.attribute_id` is defined in `cm.system__type__data_type.schema_json`.';