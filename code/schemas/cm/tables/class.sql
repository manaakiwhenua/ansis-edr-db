-- drop table if exists cm.class cascade;
create table cm.class (
	    id text not null,
	    class_model_id uuid not null,
	    identifier text not null,
	    abstract bool default false not null,
	    label text null,
        definition text null,
        editorial_note text null,
        rdf_match text[] null,
        see_also text[] null,
        root_class boolean default true not null,
        system__type_id text not null,
        system__label_template text default '${label}' null,
        system__default_location_attribute_id text null,
	    constraint pk_class
	        primary key (id),
	    constraint uq_class__identifier
	        unique (class_model_id, identifier)
            deferrable initially deferred,
	    constraint fk_class__class_model
            foreign key (class_model_id) references cm.class_model (id)
            on delete restrict on update cascade
            deferrable initially deferred,
	    constraint fk_class__system__type
            foreign key (system__type_id) references cm.system__type__class (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index if not exists fx_class__class_model on cm.class(class_model_id);
alter table cm.class owner to edr_wheel;
grant insert, update, delete on table cm.class to edr_admin, edr_jwt, edr_edit;
grant truncate on table cm.class to edr_admin;
grant select on table cm.class to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.class
    is 'Definitions of the types of classes (datasets and entities) stored the data and definition (cm) schema. Value of the type_id column on dataset and entity tables.';
comment on column cm.class.id
    is 'Class ID.';
comment on column cm.class.class_model_id
    is 'Class model UUID.';
comment on column cm.class.identifier
    is 'The formal human-readable text identifier for the class. Will be used a JSON key names or derived database table names. Format: UpperCamelCase.';
comment on column cm.class.abstract
    is 'Specifies whether the class is concrete (false - default) or abstract (true). Instances of abstract classes cannot be created.';
comment on column cm.class.label
    is ' A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.class.definition
    is 'A brief definition of the class type. Content may be formatted using Markdown syntax.';
comment on column cm.class.editorial_note
    is 'Notes on issues with the class type and any changes that may be required.';
comment on column cm.class.rdf_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable.';
comment on column cm.class.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this class type.';
comment on column cm.class.root_class
    is 'Specifies whether or not the class type is a root class in the class model.';
comment on column cm.class.system__type_id
    is 'The system level type of the class. This cannot be changed once the class is referenced by `data.dataset` or `data.entity`.';
comment on column cm.class.system__label_template
    is 'A template specifying how class attributes may be used to create a label for presentation. May be overridden by an individual dataset''s system__label_template template. Format is text with column values inserted as variables using the attribute identifier to identify the property. E.g.: ''\${depth} \[\${designation}\]''';
comment on column cm.class.system__default_location_attribute_id
    is 'The attribute id of the default geometry to be used to locate an entity when multiple spatial representations are available (e.g. `${samplingLocation}`).';
comment on constraint uq_class__identifier on cm.class
    is 'Ensures that the class identifier is unique within the class model.';