-- drop table if exists voc.concept__relationship__type cascade;
create table voc.concept__relationship__type(
        id text not null,
        label text not null,
        bidirectional boolean not null generated always as ( case when inverse_id is not null then true else false end ) stored,
        inverse_id text null,
        inverse_label text null,
        definition text null,
        super_type_id text null,
        rdf_exact_match text[] null,
        rdf_inverse_exact_match text[] null,
	    constraint pk_concept__relationship__type primary key (id),
	    constraint fk_concept__relationship__type__super_type
            foreign key (super_type_id) references voc.concept__relationship__type(id)
    );
alter table voc.concept__relationship__type owner to edr_wheel;
grant insert, update, delete on table voc.concept__relationship__type to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept__relationship__type to edr_admin;
grant select on table voc.concept__relationship__type to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept__relationship__type
    is 'Controlled list of types for a concept relationship. When the relationship is bi-direction, i.e. can be navigated in the inverse direction an `inverse_id` and `inverse_label` should be provided. For simplicity''s sake a bi-directional relationship should only be asserted in one direction.';
comment on column voc.concept__relationship__type.id
    is 'The relationship type id.';
comment on column voc.concept__relationship__type.label
    is 'A human-friendly label for the relationship type.';
comment on column voc.concept__relationship__type.bidirectional
    is '`true` if the relationship is bi-directional (has an inverse_id). Generated.';
comment on column voc.concept__relationship__type.inverse_id
    is 'The inverse relationship type id.';
comment on column voc.concept__relationship__type.inverse_label
    is 'A human-friendly label for the relationship type''s inverse relationship type (for bi-directional relationships where the relationship is consistently specified in one direction only).';
comment on column voc.concept__relationship__type.definition
    is 'A brief definition of the relationship type. Content may be formatted using Markdown syntax.';
comment on column voc.concept__relationship__type.super_type_id
    is 'The super (parent) type id where a type specialises another. E.g. narrow-match specialises match.';
comment on column voc.concept__relationship__type.rdf_exact_match
    is 'The compact URIs of the well-known RDF resource the type matches, where applicable. E.g. skos:narrowMatch.';
comment on column voc.concept__relationship__type.rdf_inverse_exact_match
    is 'The compact URIs of the well-known RDF resource the inverse of the type matches, where applicable. E.g. skos:broaderMatch.';

-- initialise table
insert into voc.concept__relationship__type (
	id,
    label,
	inverse_id,
    inverse_label,
	definition,
    super_type_id,
	rdf_exact_match,
	rdf_inverse_exact_match
)
values
    ('semantic', 'semantic relationship', null, null, 'Semantic relationships between two concepts in the same concept scheme.', null,'{skos:semanticRelation}', null),
	('related', 'related concept', null, null, 'Simple semantic relationship between two concepts.', 'semantic', '{skos:related}', null),
    ('narrower', 'narrower concept', 'broader', 'broader concept', 'Semantic relationship with a concept that represents a narrower definition (sub-set) of the concept. Inverse is `broader`.', 'semantic', '{skos:narrower}', '{skos:broader}'),
    ('narrower-transitive', 'narrower concept (transitive)', 'broader-transitive', 'broader concept (transitive)', 'Semantic relationship (direct or indirect) with a concept that represents a narrower definition (sub-set) of the concept. Inverse is `broader-transitive`.', 'semantic', '{skos:narrowerTransitive}', '{skos:broaderTransitive}'),
    ('mapping', 'mapping relationship', null, null, 'Mapping relationships map/align concepts in the different concept scheme.', null, '{skos:mappingRelation}', null),
	('exact-match', 'exact match', null, null, 'Mapping relationship with a concept in another classification scheme that is sufficiently similar that they can be used interchangeably.', 'mapping', '{skos:exactMatch}', null),
    ('close-match', 'close match', null, null, 'Mapping relationship with a concept in another classification scheme that is sufficiently similar that they can be used interchangeably in some circumstances.', 'mapping', '{skos:closeMatch}', null),
    ('narrow-match', 'narrower match', 'broader-match', 'broader match', 'Mapping relationship with a concept in another classification scheme that has a narrower definition (hierarchically it is a child concept). Inverse is `broader-match`.', 'mapping', '{skos:narrowMatch}', '{skos:broaderMatch}'),
    ('related-match', 'related match', null, null, 'Mapping a simple relationship with a concept in another classification scheme.', 'mapping', '{skos:relatedMatch}', null)
on conflict (id) do update
    set
        label = excluded.label,
        inverse_id = excluded.inverse_id,
        inverse_label = excluded.inverse_label,
        definition = excluded.definition,
        super_type_id = excluded.super_type_id,
        rdf_exact_match = excluded.rdf_exact_match,
        rdf_inverse_exact_match = excluded.rdf_inverse_exact_match;