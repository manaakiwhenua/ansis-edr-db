-- drop table if exists voc.concept__relationship cascade;
create table voc.concept__relationship (
	    id uuid default gen_random_uuid() not null,
	    type_id text not null,
	    concept_id text not null,
	    related_concept_id text not null,
	    system__order integer null,
	    constraint pk_concept__relationship
	        primary key (id),
	    constraint uq_concept__relationship__association
	        unique (type_id, concept_id, related_concept_id),
        constraint fk_concept__relationship__concept
            foreign key (concept_id) references voc.concept (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_concept__relationship__related_concept
            foreign key (related_concept_id) references voc.concept (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_concept__relationship__type
            foreign key (type_id) references voc.concept__relationship__type (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
alter table voc.concept__relationship owner to edr_wheel;
grant insert, update, delete on table voc.concept__relationship to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept__relationship to edr_admin;
grant select on table voc.concept__relationship to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept__relationship
    is 'Relates a concept to its other concepts. E.g. in a broader/narrower hierarchy. After skos:mappingRelation and skos:semanticRelation.';
comment on column voc.concept__relationship.id
    is 'Concept relationship UUID.';
comment on column voc.concept__relationship.type_id
    is 'The type of relationship.';
comment on column voc.concept__relationship.concept_id
    is 'Concept ID.';
comment on column voc.concept__relationship.related_concept_id
    is 'Related concept ID.';
comment on column voc.concept__relationship.system__order
    is 'Integer value marking the related concept''s position in a ordered collection.';
comment on constraint uq_concept__relationship__association on voc.concept__relationship
    is 'Ensures only one relationship of a given type between two concepts is allowed.';