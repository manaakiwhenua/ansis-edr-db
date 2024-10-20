-- drop table if exists voc.concept cascade;
create table voc.concept (
	    id text not null,
	    concept_scheme_id text not null,
	    top_concept boolean default true not null,
	    preferred_label text not null,
	    alternative_labels text[] null,
	    notation text null,
        definition text null,
        editorial_note text null,
        system__language text default 'en' not null,
        system__order integer null,
	    constraint pk_concept primary key (id),
	    constraint fk_concept__concept_scheme
            foreign key (concept_scheme_id) references voc.concept_scheme (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index if not exists fx_concept__concept_scheme on voc.concept(concept_scheme_id);
alter table voc.concept owner to edr_wheel;
grant insert, update, delete on table voc.concept to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept to edr_admin;
grant select on table voc.concept to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept
    is 'Concepts, or terms, in a defined vocabulary. The language used for label and definition values is set by the concept_scheme.system__language property. After skos:Concept.';
comment on column voc.concept.id
    is 'Concept ID.';
comment on column voc.concept.concept_scheme_id
    is 'Concept scheme ID';
comment on column voc.concept.top_concept
    is 'Shows whether the concept is a top (root) concept in its concept scheme. Defaults to true as most schemes a simple lists. In a hierarchy narrower concepts are, by definition, not top concepts so the value will be false.';
comment on column voc.concept.preferred_label
    is 'The preferred, human-readable, text identifier for the concept. After skos:prefLabel.';
comment on column voc.concept.alternative_labels
    is 'An array of alternative, human-readable, text identifiers for the concept (synonyms). After skos:altLabel.';
comment on column voc.concept.notation
    is 'A code, token or identifier formally used by the schema maintainers to identify and access a concept. E.g. L for the NZSC Allophanic Soils order. After skos:notation.';
comment on column voc.concept.definition
    is 'A brief definition of the concept. Content may be formatted using Markdown syntax. More detailed descriptions should be provided via the resources at the related concept_scheme.source and concept_scheme.see_also links. After skos:definition.';
comment on column voc.concept.editorial_note
    is 'Notes on issues with the concept and any changes that may be required. After skos:editorialNote.';
comment on column voc.concept.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the language used for translation. Directs the client to use a specific language for a multi-language scheme.';
comment on column voc.concept.system__order
    is 'Integer value marking the member''s position in a ordered concept scheme.';