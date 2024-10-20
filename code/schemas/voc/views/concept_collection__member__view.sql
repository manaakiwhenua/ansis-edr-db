-- drop view if exists voc.concept_collection__member__view;
create or replace view voc.concept_collection__member__view as
    select
        cc.preferred_label as concept_collection,
        ccm.concept_collection_id,
        ccm.member_concept_id,
        voc.concept__label(
            ccm.member_concept_id,
            ccm.concept_collection_id
        ) as member_label,
        ccm.system__order
    from
        voc.concept_collection__member ccm
            left join voc.concept_collection cc on ccm.concept_collection_id = cc.id
    order by
        cc.preferred_label,
        ccm.system__order;
alter view voc.concept_collection__member__view owner to edr_wheel;
grant select on table voc.concept_collection__member__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view voc.concept_collection__member__view
    is 'Human friendly view of voc.concept_collection__member. Gets preferred labels for members. Ordered by voc.concept_collection__member.system__order.';
comment on column voc.concept_collection__member__view.concept_collection
    is 'name of the concept collection.';
comment on column voc.concept_collection__member__view.concept_collection_id
    is 'Concept collection UUID.';
comment on column voc.concept_collection__member__view.member_concept_id
    is 'Member concept UUID.';
comment on column voc.concept_collection__member__view.member_label
    is 'Member concept labelled according to the concept collections label template.';
comment on column voc.concept_collection__member__view.system__order
    is 'Integer value marking the member''s position in a ordered collection.';