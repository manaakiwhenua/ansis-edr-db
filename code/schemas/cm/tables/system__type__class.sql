-- drop table if exists cm.system__type__class cascade;
create table cm.system__type__class(
        id text not null,
        identifier text not null,
        abstract boolean not null default false,
        label text not null,
        definition text null,
        super_type_id text null,
        rdf_match text[] null,
	    constraint pk_system__type__class
	        primary key (id),
	    constraint fk_system__type__class__super_type
            foreign key (super_type_id) references cm.system__type__class(id)
            deferrable initially deferred
    );
alter table cm.system__type__class owner to edr_wheel;
grant select on table cm.system__type__class to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.system__type__class
    is 'Controlled list of system types (sub-types that the system depends on) for a class type. Based largely on RDF Schema (http://www.w3.org/2000/01/rdf-schema#Class) and the [PROV-O](http://www.w3.org/ns/prov) ontology, with modifications to support the integration of the [SOSA-SSN](https://www.w3.org/TR/vocab-ssn/) sampling and observation ontology.';
comment on column cm.system__type__class.id
    is 'The system type id.';
comment on column cm.system__type__class.identifier
    is 'The formal human-readable text identifier for the class.';
comment on column cm.system__type__class.abstract
    is 'Specifies whether the class is concrete (false - default) or abstract (true). Instances of abstract classes cannot be created.';
comment on column cm.system__type__class.label
    is 'A human-friendly label for the system type.';
comment on column cm.system__type__class.definition
    is 'A brief definition of the system type. Content may be formatted using Markdown syntax.';
comment on column cm.system__type__class.super_type_id
    is 'The super (parent) system type id where a type specialises another.';
comment on column cm.system__type__class.rdf_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable.';

-- initialise table
insert into cm.system__type__class (
	id,
    identifier,
    abstract,
    label,
	definition,
    super_type_id,
	rdf_match
)
values
    ('edr-container', 'EDR_Container', true, 'EDR Container', 'Parent of classes used to organise entities. These may be `datasets` of managed `entities`, or `registers` for governance of `datasets` and `entities`.', null, null),
	('edr-dataset', 'EDR_Dataset', false, 'EDR Dataset', 'A simple class used to organise entities. They are where entities are edited and will often be associated with a project - e.g. a survey. An entity must be associated with one, and only one, dataset. Constituents of and aggregate entity share that entity''s dataset.', 'edr-container', '{http://purl.org/dc/dcmitype/Dataset}'),
	('edr-register', 'EDR_Register', false, 'EDR Register', 'A register governs datasets, and vocabulary concept schemes and lists - how their contents are created, accessed and managed. Entities may be organised into registers for publication.', 'edr-container', null),
    ('edr-collection', 'EDR_Collection', false, 'EDR Register', 'A convenient collection of `entities` grouped for a particular purpose - appropriate `Units` for a `Procedure`.', 'edr-container', null),
    ('edr-entity', 'EDR_Entity', false, 'EDR Entity', 'A class that describes identifiable ''things'' in the domain of interest. These may be real-world things or events that may have a discernible location in space and/or time. For convenience, this implementation treats agents and activities as entities.', null, '{https://www.w3.org/TR/prov-o/#Entity}')
on conflict (id) do update
    set
        label = excluded.label,
        definition = excluded.definition,
        super_type_id = excluded.super_type_id,
        rdf_match   = excluded.rdf_match;