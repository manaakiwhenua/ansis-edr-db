-- drop table if exists cm.class_model cascade;
create table cm.class_model (
	    id uuid default gen_random_uuid() not null,
        register_id uuid not null,
	    identifier text not null,
	    base_uri text not null,
	    namespace_prefix text not null,
	    label text not null,
        description text null,
        editorial_note text null,
        see_also text[] null,
	    system__type_id text not null,
	    constraint pk_class_model
	        primary key (id),
	    constraint fk_class_model__register
            foreign key (register_id) references reg.register (id)
            on delete restrict on update cascade
            deferrable initially deferred,
	    constraint fk_class_model__system__type
            foreign key (system__type_id) references cm.system__type__class_model (id)
            on delete restrict on update cascade
            deferrable initially deferred,
	    constraint uq_class_model__identifier
	        unique (identifier)
            deferrable initially deferred
	);
alter table cm.class_model owner to edr_wheel;
grant insert, update, delete on table cm.class_model to edr_admin, edr_jwt, edr_edit;
grant truncate on table cm.class_model to edr_admin;
grant select on table cm.class_model to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.class_model
    is 'Models (dare we say, ontologies?) that organise classes. Classes are defined for - and are therefore owned by - a model.';
comment on column cm.class_model.id
    is 'Class model UUID.';
comment on column cm.class_model.register_id
    is 'Governing register UUID.';
comment on column cm.class_model.identifier
    is 'The formal human-readable text identifier for the class model. Format: UpperCamelCase.';
comment on column cm.class_model.base_uri
    is 'The base URI identifying (and publishing the model). Is also the path to class and property (attribute and association) types defined in the model.';
comment on column cm.class_model.namespace_prefix
    is 'The default namespace prefix to be used in place of the base URI when identifier URIs are abbreviated as compact URIs (CURIs).';
comment on column cm.class_model.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.class_model.description
    is 'A brief description of the class model. Content may be formatted using Markdown syntax.';
comment on column cm.class_model.editorial_note
    is 'Notes on issues with the class model and any changes that may be required.';
comment on column cm.class_model.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this class model.';
comment on column cm.class_model.system__type_id
    is 'The system level type of the class model. This cannot be changed once the class model is referenced by `data.dataset`.';
comment on constraint uq_class_model__identifier on cm.class_model
    is 'Ensures that the class model identifier is unique.';