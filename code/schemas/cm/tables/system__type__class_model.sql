-- drop table if exists cm.system__type__class_model cascade;
create table cm.system__type__class_model(
        id text not null,
        label text not null,
        definition text null,
        super_type_id text null,
        rdf_match text[] null,
	    constraint pk_system__type__class_model
	        primary key (id),
	    constraint fk_system__type__class_model__super_type
            foreign key (super_type_id) references cm.system__type__class_model(id)
            deferrable initially deferred
    );
alter table cm.system__type__class_model owner to edr_wheel;
grant select on table cm.system__type__class_model to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.system__type__class_model
    is 'Controlled list of system types (sub-types that the system depends on) for a class model.';
comment on column cm.system__type__class_model.id
    is 'The system type id.';
comment on column cm.system__type__class_model.label
    is 'A human-friendly label for the system type.';
comment on column cm.system__type__class_model.definition
    is 'A brief definition of the system type. Content may be formatted using Markdown syntax.';
comment on column cm.system__type__class_model.super_type_id
    is 'The super (parent) system type id where a type specialises another.';
comment on column cm.system__type__class_model.rdf_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable.';

-- initialise table
insert into cm.system__type__class_model (
	id,
    label,
	definition,
	rdf_match
)
values
	('edr-conceptual', 'EDR Conceptual Model', 'A conceptual model aims to express the meaning of terms and concepts used by domain experts to discuss the problem, and to find the correct associations between different concepts. The conceptual model is explicitly chosen to be independent of design or implementation concerns. [https://en.wikipedia.org/wiki/Conceptual_model_(computer_science)]', null),
    ('edr-logical', 'EDR Logical Model', 'A logical model is a data model of a specific problem domain expressed independently of a particular database management product or storage technology (physical data model) but does define elements of the data structure (attributes, data types etc). [https://en.wikipedia.org/wiki/Logical_schema]', null),
    ('edr-physical', 'EDR Physical Model', 'A physical data model is a representation of a data design as implemented, or intended to be implemented, in a database management system or other data structure (e.g. a JSON or XML schema. [https://en.wikipedia.org/wiki/Physical_schema]',null)
on conflict (id) do update
    set
        label = excluded.label,
        definition = excluded.definition,
        rdf_match   = excluded.rdf_match;