-- drop table if exists voc.concept_scheme__translation cascade;
create table voc.concept_scheme__translation (
	    id uuid default gen_random_uuid() not null,
	    concept_scheme_id text not null,
	    preferred_label text not null,
        description text null,
        editorial_note text null,
        system__language text not null,
	    constraint pk_concept_scheme__translation
	        primary key (id),
	    constraint fk_concept_scheme__translation__concept_scheme
            foreign key (concept_scheme_id) references voc.concept_scheme (id)
            on delete cascade on update cascade
            deferrable initially deferred
	);
create index if not exists fx_concept_scheme__translation__concept_scheme on voc.concept_scheme__translation(concept_scheme_id);
alter table voc.concept_scheme__translation owner to edr_wheel;
grant insert, update, delete on table voc.concept_scheme__translation to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept_scheme__translation to edr_admin;
grant select on table voc.concept_scheme__translation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept_scheme__translation
    is 'Concept scheme label and description properties as translated into the language specified in system__language.';
comment on column voc.concept_scheme__translation.id
    is 'Concept scheme translation UUID.';
comment on column voc.concept_scheme__translation.concept_scheme_id
    is 'Concept scheme ID.';
comment on column voc.concept_scheme__translation.preferred_label
    is 'Translation of the preferred, human-readable, text identifier for the concept scheme. After skos:prefLabel.';
comment on column voc.concept_scheme__translation.description
    is 'Translation of the brief description of the concept scheme. Content may be formatted using Markdown syntax.Content may be formatted using Markdown syntax.';
comment on column voc.concept_scheme__translation.editorial_note
    is 'Translation of the notes on issues with the concept scheme and any changes that may be required. After skos:editorialNote.';
comment on column voc.concept_scheme__translation.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the language used for translation. Directs the client to use a specific language for a multi-language scheme.';