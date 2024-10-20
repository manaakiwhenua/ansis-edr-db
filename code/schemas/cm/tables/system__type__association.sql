-- drop table if exists cm.system__type__association cascade;
create table cm.system__type__association(
        id text not null,
        label text not null,
        definition text null,
        super_type_id text null,
        rdf_match text[] null,
	    constraint pk_system__type_association primary key (id),
	    constraint fk_system__type_association__super_type
            foreign key (super_type_id) references cm.system__type__association(id)
    );
alter table cm.system__type__association owner to edr_wheel;
grant select on table cm.system__type__association to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.system__type__association
    is 'Controlled list of system types (sub-types that the system depends on) for a association type.';
comment on column cm.system__type__association.id
    is 'The system type id.';
comment on column cm.system__type__association.label
    is 'A human-friendly label for the system type.';
comment on column cm.system__type__association.definition
    is 'A brief definition of the system type. Content may be formatted using Markdown syntax.';
comment on column cm.system__type__association.super_type_id
    is 'The super (parent) system type id where a type specialises another.';
comment on column cm.system__type__association.rdf_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable.';

-- initialise table
insert into cm.system__type__association (
	id,
    label,
	definition,
    super_type_id,
	rdf_match
)
values
	('edr-entity-relationship', 'EDR Relationship', 'A simple association between two independent classes.', null, null),
    ('edr-entity-aggregation', 'EDR Aggregation', 'An aggregation of instances of classes where the constituent class cannot exist independently. Deleting these associations is restricted - constituents must either be associated with a different class or removed.', null, null)
on conflict (id) do update
    set
        label = excluded.label,
        definition = excluded.definition,
        rdf_match   = excluded.rdf_match;