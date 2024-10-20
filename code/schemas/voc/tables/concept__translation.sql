-- drop table if exists voc.concept__translation cascade;
create table voc.concept__translation (
	    id uuid default gen_random_uuid() not null,
	    concept_id text not null,
	    preferred_label text not null,
	    alternative_labels text[] null,
        definition text null,
        editorial_note text null,
        system__language text not null,
	    constraint pk_concept__translation
	        primary key (id),
	    constraint fk_concept__translation__concept
            foreign key (concept_id) references voc.concept (id)
            on delete cascade on update cascade
            deferrable initially deferred
	);
create index if not exists fx_concept__translation__concept on voc.concept__translation(concept_id);
alter table voc.concept__translation owner to edr_wheel;
grant insert, update, delete on table voc.concept__translation to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept__translation to edr_admin;
grant select on table voc.concept__translation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept__translation
    is 'Concept scheme label and description properties as translated into the language specified in system__language.';
comment on column voc.concept__translation.id
    is 'Concept translation UUID.';
comment on column voc.concept__translation.concept_id
    is 'Concept ID.';
comment on column voc.concept__translation.preferred_label
    is 'Translation of the preferred, human-readable, text identifier for the concept. After skos:prefLabel.';
comment on column voc.concept__translation.alternative_labels
    is 'Translation of the alternative, human-readable, text identifiers for the concept. After skos:prefLabel.';
comment on column voc.concept__translation.definition
    is 'Translation of the brief description of the concept. Content may be formatted using Markdown syntax.';
comment on column voc.concept__translation.editorial_note
    is 'Translation of the notes on issues with the concept and any changes that may be required. After skos:editorialNote.';
comment on column voc.concept__translation.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the language used for translation. Directs the client to use a specific language for a multi-language scheme.';