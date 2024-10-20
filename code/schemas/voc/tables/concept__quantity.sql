-- drop table if exists voc.concept__quantity cascade;
create table voc.concept__quantity (
	    id uuid default gen_random_uuid() not null,
	    concept_id text not null,
	    value numrange not null,
	    uom_id text not null,
	    constraint pk_concept__quantity
	        primary key (id)/*,
	    constraint fk_concept__quantity__uom
            foreign key (uom_id) references voc.concept (id)
            on delete cascade on update cascade
            deferrable initially deferred*/
	);
alter table voc.concept__quantity owner to edr_wheel;
grant insert, update, delete on table voc.concept__quantity to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept__quantity to edr_admin;
grant select on table voc.concept__quantity to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept__quantity
    is 'Extends voc.concept to provide the applicable numeric values for concepts that actually describe a numeric range. E.g. an abundance or size fraction vocabulary. The unit of measure used is as defined in the source vocabulary.';
comment on column voc.concept__quantity.id
    is 'Concept quantity UUID.';
comment on column voc.concept__quantity.concept_id
    is 'Concept ID.';
comment on column voc.concept__quantity.value
    is 'The numeric range represented by the concept.';
comment on column voc.concept__quantity.uom_id
    is 'The range value''s unit of measure.';