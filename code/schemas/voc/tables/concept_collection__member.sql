-- drop table if exists voc.concept_collection__member cascade;
create table voc.concept_collection__member (
	    id uuid default gen_random_uuid() not null,
	    concept_collection_id uuid not null,
	    member_concept_id text not null,
	    system__order integer null,
	    constraint pk_concept_collection__member primary key (id),
	    constraint fk_concept_collection__member__concept_collection
            foreign key (concept_collection_id) references voc.concept_collection (id)
            on delete cascade on update cascade
            deferrable initially deferred,
	    constraint fk_concept_collection__member__concept
            foreign key (member_concept_id) references voc.concept (id)
            on delete cascade on update cascade
            deferrable initially deferred
	);
alter table voc.concept_collection__member owner to edr_wheel;
grant insert, update, delete on table voc.concept_collection__member to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept_collection__member to edr_admin;
grant select on table voc.concept_collection__member to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept_collection__member
    is 'Relates a collection to its member concepts.';
comment on column voc.concept_collection__member.id
    is 'Concept collection member UUID.';
comment on column voc.concept_collection__member.concept_collection_id
    is 'Concept collection UUID.';
comment on column voc.concept_collection__member.member_concept_id
    is 'Member concept ID.';
comment on column voc.concept_collection__member.system__order
    is 'Integer value marking the member''s position in a ordered collection.';