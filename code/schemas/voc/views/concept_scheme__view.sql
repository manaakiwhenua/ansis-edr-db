-- drop view if exists voc.concept_scheme__view;
create or replace view voc.concept_scheme__view as
    with _top_concepts as (
            select
                tc.concept_scheme_id,
                array_agg(
                    voc.concept__label(
                        _concept_id => tc.id
                    )
                    order by
                        1
                ) as top_concepts
            from
                voc.concept tc
                    left join voc.concept_scheme cs on tc.concept_scheme_id = cs.id
            where
                tc.top_concept
            group by
                tc.concept_scheme_id
        ),
        _lower_concepts as (
            select
                lc.concept_scheme_id,
                array_agg(
                    voc.concept__label(
                        _concept_id => lc.id
                    )
                    order by
                        1
                ) as lower_concepts
            from
                voc.concept lc
                    left join voc.concept_scheme cs on lc.concept_scheme_id = cs.id
            where
                not(lc.top_concept)
            group by
                lc.concept_scheme_id
        )
    select
        cs.id,
        cs.preferred_label,
        cs.notation,
        cs.description,
        tc.top_concepts,
        lc.lower_concepts,
        cs.source,
        cs.see_also,
        cs.system__language,
        cs.system__label_template
    from
        voc.concept_scheme cs
            left join _top_concepts tc on cs.id = tc.concept_scheme_id
            left join _lower_concepts lc on cs.id = lc.concept_scheme_id
    order by
        preferred_label;
alter view voc.concept_scheme__view owner to edr_wheel;
grant select on table voc.concept_scheme__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view voc.concept_scheme__view
    is 'Human friendly view of voc.concept_scheme. Gets labels for UUIDs and aggregates labels of related entities into arrays.';
comment on column voc.concept_scheme__view.id
    is 'Concept scheme UUID.';
comment on column voc.concept_scheme__view.preferred_label
    is 'The preferred, human-readable, text identifier for the concept scheme. After skos:prefLabel.';
comment on column voc.concept_scheme__view.notation
    is 'A code, token or identifier formally used by the schema maintainers to identify and access a concept scheme. E.g. NZSC for the ... NZSC. After skos:notation.';
comment on column voc.concept_scheme__view.description
    is 'A brief description of the concept concept scheme. Content may be formatted using Markdown syntax. More detailed descriptions should be provided via the resources at the related concept_scheme.source and concept_scheme.see_also links.';
comment on column voc.concept_scheme__view.top_concepts
    is 'An array of concepts that are at the root (top) of the concept scheme.';
comment on column voc.concept_scheme__view.lower_concepts
    is 'An array of concepts that are at the narrower concepts of the concept scheme''s top concepts.';
comment on column voc.concept_scheme__view.source
    is 'An array of citations (preferably DOIs or other URIs) for the source of the data in the concept scheme.';
comment on column voc.concept_scheme__view.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this concept scheme.';
comment on column voc.concept_scheme__view.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the default language used for concept labels, descriptions and definitions when the concept scheme is used. Directs the client to use a specific language for a multi-language scheme. If null, the default concept_scheme.system__language is used.';
comment on column voc.concept_scheme__view.system__label_template
    is 'A template specifying how the concept preferred_label and notation values are to be used to great a label for presentation. May be overridden by the concept_concept scheme system__label_template template. Format is text with preferred_label and notation column values inserted as variables (\${preferred_label} and \${notation}). E.g.: ''\${preferred_label} \[\${notation}\]''';