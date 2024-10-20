-- drop table if exists voc.concept_collection cascade;
create table voc.concept_collection (
	    id uuid default gen_random_uuid() not null,
        register_id uuid not null,
	    preferred_label text not null,
	    notation text null,
        description text null,
        default_concept_id text null,
        editorial_note text null,
	    system__ordered boolean default true not null,
        system__language text default 'en' null,
        system__label_template text null,
        system__tag text[] null,
	    constraint pk_concept_collection primary key (id),
	    constraint fk_concept_scheme__register
            foreign key (register_id) references reg.register (id)
            on delete restrict on update cascade
            deferrable initially deferred,
	    constraint uq_concept_collection__notation unique (notation)
	);
create index if not exists fx_concept_collection__register on voc.concept_collection(register_id);
alter table voc.concept_collection owner to edr_wheel;
grant insert, update, delete on table voc.concept_collection to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept_collection to edr_admin;
grant select on table voc.concept_collection to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept_collection
    is 'A collection of concepts describing the same property, or a subset of a vocabulary''s concepts required by an application. Potentially a publication, or a chapter within a publication. After skos:Collection and skos:OrderedCollection.';
comment on column voc.concept_collection.id
    is 'Concept collection UUID.';
comment on column voc.concept_collection.register_id
    is 'Governing register UUID.';
comment on column voc.concept_collection.preferred_label
    is 'The preferred, human-readable, text identifier for the collection. After skos:prefLabel.';
comment on column voc.concept_collection.notation
    is 'A code, token or identifier formally used by the schema maintainers to identify and access a collection. E.g. NZSC for the ... NZSC. After skos:notation.';
comment on column voc.concept_collection.description
    is 'A brief description of the concept collection. Content may be formatted using Markdown syntax. More detailed descriptions should be provided via the resources at the related concept_scheme.source and concept_scheme.see_also links.';
comment on column voc.concept_collection.default_concept_id
    is 'The UUID of the concept to be used as the default value for properties populated by the concept collection (where appropriate).';
comment on column voc.concept_collection.editorial_note
    is 'Notes on issues with the concept and any changes that may be required. After skos:editorialNote.';
comment on column voc.concept_collection.system__ordered
    is 'Specifies whether the collection members are ordered. Ordering may either be in natural ascending/descending alphanumeric order, or as specified by the vocabulary maintainer. `true` means the collection is a skos:OrderedCollection.';
comment on column voc.concept_collection.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the default language used for concept labels, descriptions and definitions when the collection is used. Directs the client to use a specific language for a multi-language scheme. If null, the default concept_scheme.system_language is used.';
comment on column voc.concept_collection.system__label_template
    is 'A template specifying how the concept preferred_label and notation values are to be used to great a label for presentation. May be overridden by the concept_collection system__label_template template. Format is text with preferred_label and notation column values inserted as variables (\${preferred_label} and \${notation}). E.g.: ''\${preferred_label} \[\${notation}\]''';
comment on column voc.concept_collection.system__tag
    is 'An array of tags that can be used to group or otherwise organise concept schemes.';
comment on constraint uq_concept_collection__notation on voc.concept_collection
    is 'Ensures the `notation` value is unique as it is used for HTTP URIs.';