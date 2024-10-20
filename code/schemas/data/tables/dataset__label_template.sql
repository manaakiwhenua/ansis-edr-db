-- drop table if exists data.dataset__label_template cascade;
create table data.dataset__label_template (
	    dataset_id uuid not null,
	    class_id text not null,
	    system__label_template text null,
	    constraint pk_dataset__label_template primary key (dataset_id, class_id),
	    constraint fk_dataset__label_template__dataset foreign key (dataset_id)
	        references data.dataset (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_dataset__label_template__class foreign key (class_id)
            references cm.class (id)
            on delete cascade on update cascade
            deferrable initially deferred
	);
create index if not exists fx_dataset__label_template__dataset on data.dataset__label_template(dataset_id);
create index if not exists fx_dataset__label_template__class on data.dataset__label_template(class_id);
alter table	data.dataset__label_template owner to edr_wheel;
grant insert, update, delete on table data.dataset__label_template to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.dataset__label_template to edr_admin;
grant select on table data.dataset__label_template to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.dataset__label_template
	is 'Templates for the default_label property for a given class as defined for specific datasets. Used to override the class''s default template.';
comment on column data.dataset__label_template.dataset_id
    is 'Dataset UUID';
comment on column data.dataset__label_template.class_id
    is 'Class UUID.';
comment on column data.dataset__label_template.system__label_template
    is 'A template specifying how class attributes may be used to create a label for presentation. Used to override the class''s default system__label_template template. Format is text with column values inserted as variables using the attribute identifier to identify the property. E.g.: ''\${depth} \[\${designation}\]''';