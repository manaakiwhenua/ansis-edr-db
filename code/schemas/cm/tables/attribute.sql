-- drop table if exists cm.attribute cascade;
create table cm.attribute (
	    id text not null,
	    class_model_id uuid not null,
	    identifier text not null,
        data_type_id text not null,
        abstract boolean default false not null,
        derived boolean default false not null,
	    label text null,
        definition text null,
        editorial_note text null,
        rdf_match text[] null,
        see_also text[] null,
        constraints jsonb null,
        system__type_id text not null,
	    constraint pk_attribute primary key (id),
	    constraint uq_attribute__identifier unique (class_model_id, identifier)
            deferrable initially deferred,
	    constraint fk_attribute__class_model
            foreign key (class_model_id) references cm.class_model (id)
            on delete restrict on update cascade
            deferrable initially deferred,
        constraint fk_attribute__data_type
            foreign key (data_type_id) references cm.system__type__data_type (id)
            on delete restrict on update cascade
            deferrable initially deferred,
	    constraint fk_attribute__system__type
            foreign key (system__type_id) references cm.system__type__attribute (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index if not exists fx_attribute__class_model on cm.attribute(class_model_id);
alter table cm.attribute owner to edr_wheel;
grant insert, update, delete on table cm.attribute to edr_admin, edr_jwt, edr_edit;
grant truncate on table cm.attribute to edr_admin;
grant select on table cm.attribute to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.attribute
    is 'Definitions of the types of properties stored the data and definition (cm) schema. Value of the type_id column on _attribute, _assertion, _observation and _measurement tables.';
comment on column cm.attribute.id
    is 'Attribute ID.';
comment on column cm.attribute.class_model_id
    is 'Class model UUID.';
comment on column cm.attribute.identifier
    is 'The formal human-readable text identifier for the attribute type. Will be used a JSON key names or derived database column names. Format: lowerCamelCase.';
comment on column cm.attribute.data_type_id
    is 'The data type of the attribute. For attributes with polymorphic data types, specialise the attribute by data types.';
comment on column cm.attribute.abstract
    is 'Specifies whether the attribute class is concrete (false - default) or abstract (true). Instances of abstract attribute classes cannot be created.';
comment on column cm.attribute.derived
    is 'Specifies whether the attribute is concrete (false - default) or derived (true). Derived properties are a function of one or more concrete attribute types.';
comment on column cm.attribute.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.attribute.definition
    is 'A brief definition of the attribute type. Content may be formatted using Markdown syntax.';
comment on column cm.attribute.editorial_note
    is 'Notes on issues with the attribute type and any changes that may be required.';
comment on column cm.attribute.rdf_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable.';
comment on column cm.attribute.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this attribute type.';
comment on column cm.attribute.constraints
    is 'The default constraints on the value of an instance of a attribute. Managed as a JSON object as applicable constraints vary with the attribute type''s range.';
comment on column cm.attribute.system__type_id
    is 'The system level type of the attribute. This cannot be changed once the attribute is referenced by `data.*_attribute|observation|measurement` tables.';
comment on constraint uq_attribute__identifier on cm.attribute
    is 'Ensures that the attribute identifier is unique within the class model.';

alter table cm.class add constraint fk_class__system__default_location_attribute
    foreign key (system__default_location_attribute_id) references cm.attribute (id)
    on delete restrict on update cascade
    deferrable initially deferred;