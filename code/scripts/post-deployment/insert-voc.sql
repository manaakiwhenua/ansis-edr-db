-- add vocabs from JSON enumerations via working views
insert into
    voc.concept_scheme(
        id, register_id, preferred_label, notation, description, editorial_note, source, see_also, system__language, system__label_template, system__tag
    )
select
    id, register_id, preferred_label, notation, description, editorial_note, source, see_also, system__language, system__label_template, system__tag
from
    working.concept_scheme;

insert into
    voc.concept(
        id, concept_scheme_id, preferred_label, alternative_labels, notation, definition, editorial_note, system__order
    )
select
    id, concept_scheme_id, preferred_label, alternative_labels, notation, definition, editorial_note, system__order
from
    working.concept;