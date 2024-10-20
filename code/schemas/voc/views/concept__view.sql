-- drop view if exists voc.concept__view;
create or replace view voc.concept__view as
    with _broader as (
            select
                cr.related_concept_id as concept_id,
                array_agg(
                    cl order by cl
                ) as broader
            from
                voc.concept__relationship cr,
                voc.concept__label(
                    _concept_id => cr.concept_id
                ) cl
            where
                cr.type_id ~ 'broader'
            group by
                cr.related_concept_id
        ),
        _narrower as (
            select
                cr.concept_id,
                array_agg(
                    cl order by cl
                ) as narrower
            from
                voc.concept__relationship cr,
                voc.concept__label(
                    _concept_id => cr.related_concept_id
                ) cl
            where
                cr.type_id ~ 'narrower'
            group by
                cr.concept_id
        ),
        _related as (
            select
                cr.concept_id,
                array_agg(
                    cl order by cl
                ) as related
            from
                voc.concept__relationship cr,
                voc.concept__label(
                    _concept_id => cr.related_concept_id
                ) cl
            where
                cr.type_id ~ 'related'
            group by
                cr.concept_id
        ),
        _match as (
            select
                cr.concept_id,
                array_agg(
                    cl order by cl
                ) as matching
            from
                voc.concept__relationship cr,
                voc.concept__label(
                    _concept_id => cr.related_concept_id
                ) cl
            where
                cr.type_id ~ 'match'
            group by
                cr.concept_id
        )
    select
        c.id,
        cs.preferred_label as in_scheme,
        c.top_concept,
        voc.concept__label(
            _concept_id => c.id
        ) as label,
        c.preferred_label,
        c.alternative_labels,
        c.notation,
        c.definition,
        bc.broader,
        nc.narrower,
        rc.related,
        mc.matching
    from
        voc.concept c
            left join voc.concept_scheme cs on c.concept_scheme_id = cs.id
            left join _broader bc on bc.concept_id = c.id
            left join _narrower nc on nc.concept_id = c.id
            left join _related rc on bc.concept_id = c.id
            left join _match mc on nc.concept_id = c.id
    order by
        in_scheme,
        top_concept desc,
        notation,
        preferred_label;
alter view voc.concept__view owner to edr_wheel;
grant select on table voc.concept__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view voc.concept__view
    is 'Human friendly view of voc.concept. Gets labels for UUIDs and aggregates labels of related entities into arrays.';
comment on column voc.concept__view.id
    is 'Concept UUID.';
comment on column voc.concept__view.in_scheme
    is 'Concept scheme the concept is a member of.';
comment on column voc.concept__view.top_concept
    is 'Shows whether the concept is a top (root) concept in its concept scheme. Defaults to true as most schemes a simple lists. In a hierarchy narrower concepts are, by definition, not top concepts so the value will be false.';
comment on column voc.concept__view.label
    is 'The formatted label, structured according to the label template defined for the concept scheme';
comment on column voc.concept__view.preferred_label
    is 'The preferred, human-readable, text identifier for the concept. After skos:prefLabel.';
comment on column voc.concept__view.alternative_labels
    is 'An array of alternative, human-readable, text identifiers for the concept (synonyms). After skos:altLabel.';
comment on column voc.concept__view.notation
    is 'A code, token or identifier formally used by the schema maintainers to identify and access a concept. E.g. L for the NZSC Allophanic Soils order. After skos:notation.';
comment on column voc.concept__view.definition
    is 'A brief definition of the concept. Content may be formatted using Markdown syntax. More detailed descriptions should be provided via the resources at the related concept_scheme.source and concept_scheme.see_also links. After skos:definition.';
comment on column voc.concept__view.broader
    is 'Array of broader (parent) concepts.';
comment on column voc.concept__view.narrower
    is 'Array of narrower (child) concepts.';
comment on column voc.concept__view.related
    is 'Array of concepts that have a simple semantic relationship with the concept.';
comment on column voc.concept__view.matching
    is 'Array of matching (exact, close, narrower or broader) concepts from another schema.';