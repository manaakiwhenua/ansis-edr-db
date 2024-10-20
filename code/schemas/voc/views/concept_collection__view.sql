-- drop view if exists voc.concept_collection__view;
create or replace view voc.concept_collection__view as
    with _members as (
            select
                ccm.concept_collection_id as id,
                array_agg(
                    ccm.member_label
                    order by
                        1
                ) as members
            from
                voc.concept_collection__member__view ccm
            group by
                ccm.concept_collection_id
        )
    select
        cc.id,
        cc.preferred_label,
        cc.notation,
        cc.description,
        mc.members,
        cc.system__language,
        cc.system__label_template
    from
        voc.concept_collection cc
            left join _members mc on cc.id = mc.id
    order by
        preferred_label;
alter view voc.concept_collection__view owner to edr_wheel;
grant select on table voc.concept_collection__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view voc.concept_collection__view
    is 'Human friendly view of voc.concept_collection. Gets labels for UUIDs and aggregates labels of related entities into arrays.';
comment on column voc.concept_collection__view.id
    is 'Concept collection UUID.';
comment on column voc.concept_collection__view.preferred_label
    is 'The preferred, human-readable, text identifier for the collection. After skos:prefLabel.';
comment on column voc.concept_collection__view.notation
    is 'A code, token or identifier formally used by the schema maintainers to identify and access a collection. E.g. NZSC for the ... NZSC. After skos:notation.';
comment on column voc.concept_collection__view.description
    is 'A brief description of the concept collection. Content may be formatted using Markdown syntax. More detailed descriptions should be provided via the resources at the related concept_scheme.source and concept_scheme.see_also links.';
comment on column voc.concept_collection__view.members
    is 'Array of concepts that are members of this collection.';
comment on column voc.concept_collection__view.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the default language used for concept labels, descriptions and definitions when the collection is used. Directs the client to use a specific language for a multi-language scheme. If null, the default concept_scheme.system__language is used.';
comment on column voc.concept_collection__view.system__label_template
    is 'A template specifying how the concept preferred_label and notation values are to be used to great a label for presentation. May be overridden by the concept_collection system__label_template template. Format is text with preferred_label and notation column values inserted as variables (\${preferred_label} and \${notation}). E.g.: ''\${preferred_label} \[\${notation}\]''';