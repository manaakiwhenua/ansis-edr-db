-- drop view if exists voc.concept__relationship__with_inverse cascade;
create or replace view voc.concept__relationship__with_inverse as
    select
        cr.id,
        cr.concept_id,
        cr.type_id,
        cr.related_concept_id,
        cr.system__order
    from
        voc.concept__relationship cr
    union
    select
        cr.id,
        cr.related_concept_id as concept_id,
        crt.inverse_id as type_id,
        cr.concept_id as related_concept_id,
        cr.system__order
    from
        voc.concept__relationship cr
            join voc.concept__relationship__type crt
                on cr.type_id = crt.id
    where
        crt.bidirectional;
alter view voc.concept__relationship__with_inverse owner to edr_wheel;
grant select on table voc.concept__relationship__with_inverse to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view voc.concept__relationship__with_inverse
    is 'View extending voc.concept__relationship to includes inverse relationships as records.';
comment on column voc.concept__relationship__with_inverse.id
    is 'Concept relationship UUID.';
comment on column voc.concept__relationship__with_inverse.type_id
    is 'The type of relationship.';
comment on column voc.concept__relationship__with_inverse.concept_id
    is 'Concept UUID.';
comment on column voc.concept__relationship__with_inverse.related_concept_id
    is 'Related concept UUID.';
comment on column voc.concept__relationship__with_inverse.system__order
    is 'Integer value marking the related concept''s position in a ordered collection.';