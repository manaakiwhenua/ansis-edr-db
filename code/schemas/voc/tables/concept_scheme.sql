-- drop table if exists voc.concept_scheme cascade;
create table voc.concept_scheme (
	    id text not null,
        register_id uuid not null,
	    preferred_label text not null,
	    notation text null,
        description text null,
        editorial_note text null,
        source text[] null,
        see_also text[] null,
        system__language text default 'en' not null,
        system__label_template text default '${preferred_label}' null,
        system__tag text[] null,
	    constraint pk_concept_scheme primary key (id),
	    constraint fk_concept_scheme__register
            foreign key (register_id) references reg.register (id)
            on delete restrict on update cascade
            deferrable initially deferred
	);
create index if not exists fx_concept_scheme__register on voc.concept_scheme(register_id);
alter table voc.concept_scheme owner to edr_wheel;
grant insert, update, delete on table voc.concept_scheme to edr_admin, edr_jwt, edr_edit;
grant truncate on table voc.concept_scheme to edr_admin;
grant select on table voc.concept_scheme to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table voc.concept_scheme
    is 'A vocabulary or similar collection of concepts with a common source and history of governance. Potentially a publication, or a chapter within a publication. After skos:concept_scheme.';
comment on column voc.concept_scheme.id
    is 'Concept scheme ID.';
comment on column voc.concept_scheme.register_id
    is 'Governing register UUID.';
comment on column voc.concept_scheme.preferred_label
    is 'The preferred, human-readable, text identifier for the concept scheme. After skos:prefLabel.';
comment on column voc.concept_scheme.notation
    is 'A code, token or identifier formally used by the schema maintainers to identify and access a concept scheme. E.g. NZSC for the ... NZSC. After skos:notation.';
comment on column voc.concept_scheme.description
    is 'A brief description of the concept concept scheme. Content may be formatted using Markdown syntax. More detailed descriptions should be provided via the resources at the related concept_scheme.source and concept_scheme.see_also links.';
comment on column voc.concept_scheme.editorial_note
    is 'Notes on issues with the concept and any changes that may be required. After skos:editorialNote.';
comment on column voc.concept_scheme.source
    is 'An array of citations (preferably DOIs or other URIs) for the source of the data in the concept scheme.';
comment on column voc.concept_scheme.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this concept scheme.';
comment on column voc.concept_scheme.system__language
    is 'An [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) for the default language used for concept labels, descriptions and definitions when the concept scheme is used. Directs the client to use a specific language for a multi-language scheme. If null, the default concept_scheme.system__language is used.';
comment on column voc.concept_scheme.system__label_template
    is 'A template specifying how the concept preferred_label and notation values are to be used to great a label for presentation. May be overridden by the concept_concept scheme system__label_template template. Format is text with preferred_label and notation column values inserted as variables (\${preferred_label} and \${notation}). E.g.: ''\${preferred_label} \[\${notation}\]''';
comment on column voc.concept_scheme.system__tag
    is 'An array of tags that can be used to group or otherwise organise concept schemes.';