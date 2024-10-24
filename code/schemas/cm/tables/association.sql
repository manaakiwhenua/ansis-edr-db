-- drop table if exists cm.association cascade;
create table cm.association (
	    id text not null,
	    class_model_id uuid not null,
	    source_class_id text not null,
	    target_class_id text not null,
	    identifier text not null,
	    label text null,
        bidirectional boolean not null generated always as ( case when inverse_identifier is not null then true else false end ) stored,
        inverse_identifier text null,
        inverse_label text null,
        constraint__multiplicity integer[],
        definition text null,
        editorial_note text null,
        rdf_match text[] null,
        see_also text[] null,
        constraints jsonb null,
        system__type_id text not null,
	    constraint pk_association
	        primary key (id),
-- 	    constraint uq_association__identifier
-- 	        unique (class_model_id, identifier)
--             deferrable initially deferred,
	    constraint fk_association__class_model
            foreign key (class_model_id) references cm.class_model (id)
            on delete restrict on update cascade
            deferrable initially deferred,
        constraint fk_association__source_class
            foreign key (source_class_id) references cm.class (id)
                on delete restrict on update cascade
                deferrable initially deferred,
        constraint fk_association__target_class
            foreign key (target_class_id) references cm.class (id)
                on delete restrict on update cascade
                deferrable initially deferred,
	    constraint fk_association__system__type
            foreign key (system__type_id) references cm.system__type__association (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
alter table cm.association owner to edr_wheel;
grant insert, update, delete on table cm.association to edr_admin, edr_jwt, edr_edit;
grant truncate on table cm.association to edr_admin;
grant select on table cm.association to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.association
    is 'An association is a special type of attribute that connects classes to each other. The may be simple `relationships`, describing a relationship between independent classes, or an `aggregation` between classes made up of other classes.';
comment on column cm.association.id
    is 'Association ID.';
comment on column cm.association.class_model_id
    is 'Class model UUID.';
comment on column cm.association.source_class_id
    is 'Association''s source class ID.';
comment on column cm.association.target_class_id
    is 'Association''s target class ID.';
comment on column cm.association.identifier
    is 'The formal human-readable text identifier for the association type. Will be used a JSON key names or derived database column names. Format: lowerCamelCase';
comment on column cm.association.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.association.bidirectional
    is '`true` if the association is bi-directional (has an inverse_id). Generated.';
comment on column cm.association.inverse_identifier
    is 'The inverse association type identifier.';
comment on column cm.association.inverse_label
    is 'A human-friendly label for the association type''s inverse association type (for bi-directional associations where the association is consistently specified in one direction only).';
comment on column cm.association.constraint__multiplicity
    is 'Target class multiplicity.';
comment on column cm.association.definition
    is 'A brief definition of the association type. Content may be formatted using Markdown syntax';
comment on column cm.association.editorial_note
    is 'Notes on issues with the association type and any changes that may be required.';
comment on column cm.association.rdf_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable.';
comment on column cm.association.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this association type.';
comment on column cm.association.constraints
    is 'The default constraints on the value of an instance of a association_type. Managed as a JSON object as applicable constraints vary with the association type''s range.';
comment on column cm.association.system__type_id
    is 'The system level type of the association. This cannot be changed once the attribute is referenced by `data.*_aggregation|association` tables.';
-- comment on constraint uq_association__identifier on cm.association
--     is 'Ensures that the association identifier is unique within the class model.';