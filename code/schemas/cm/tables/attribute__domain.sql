-- drop table if exists cm.attribute__domain cascade;
create table cm.attribute__domain (
	    id uuid default gen_random_uuid() not null,
	    attribute_id text not null,
	    class_id text not null,
	    constraint__multiplicity integer[] default '{0,1}'::integer[] not null,
	    constraint__value_collection_id uuid,
        constraint__value_unit_collection_id uuid,
        constraint__procedure_collection_id uuid,
        constraint__agent_collection_id uuid,
	    constraint pk_attribute__domain
	        primary key (id),
	    constraint uq_attribute__domain__association
	        unique (attribute_id, class_id)
            deferrable initially deferred,
	    constraint fk_attribute__domain__attribute
            foreign key (attribute_id) references cm.attribute (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_attribute__domain__class
            foreign key (class_id) references cm.class (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_attribute__domain__constraint__value_collection
            foreign key (constraint__value_collection_id) references voc.concept_collection (id)
            on delete restrict on update cascade
            deferrable initially deferred,
        constraint fk_attribute__domain__constraint__value_unit_collection
            foreign key (constraint__value_unit_collection_id) references voc.concept_collection (id)
            on delete restrict on update cascade
            deferrable initially deferred,
        constraint fk_attribute__domain__constraint__procedure_collection
            foreign key (constraint__procedure_collection_id) references voc.concept_collection (id)
            on delete restrict on update cascade
            deferrable initially deferred,
        constraint fk_attribute__domain__constraint__agent_collection
            foreign key (constraint__agent_collection_id) references voc.concept_collection (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
-- create index if not exists fx_attribute__domain__attribute on cm.attribute__domain(attribute_id);
-- create index if not exists fx_attribute__domain__class on cm.attribute__domain(class_id);
alter table cm.attribute__domain owner to edr_wheel;
grant insert, update, delete on table cm.attribute__domain to edr_admin, edr_jwt, edr_edit;
grant truncate on table cm.attribute__domain to edr_admin;
grant select on table cm.attribute__domain to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.attribute__domain
    is 'Relates properties to their domain - the class of which the attribute is an attribute. Properties may be shared by multiple classes.';
comment on column cm.attribute__domain.id
    is 'Attribute domain UUID.';
comment on column cm.attribute__domain.attribute_id
    is 'Attribute ID.';
comment on column cm.attribute__domain.class_id
    is 'Class ID.';
comment on column cm.attribute__domain.constraint__multiplicity
    is 'A two element array specifying the minimum and maximum allowable number of attribute type values for a specific class. This may vary between classes.';
comment on column cm.attribute__domain.constraint__value_collection_id
    is 'The UUID of the concept_collection_id that specified the available concepts for concept reference attributes.';
comment on constraint uq_attribute__domain__association on cm.attribute__domain
    is 'Ensures only one domain association between a attribute and a class is created.';