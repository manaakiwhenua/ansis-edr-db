-- add class model elements from JSON schema via working views

insert into
    cm.class_model(
        id, register_id, identifier, base_uri, namespace_prefix, label, description, editorial_note, see_also, system__type_id
    )
select
    id, register_id, identifier, base_uri, namespace_prefix, label, description, editorial_note, see_also, system__type_id
from
    working.class_model;

insert into
    cm.class(
        id, class_model_id, identifier, abstract, label, definition, editorial_note, rdf_match, see_also, root_class, system__type_id, system__label_template, system__default_location_attribute_id
    )
select
    id, class_model_id, identifier, abstract, label, definition, editorial_note, rdf_match, see_also, root_class, system__type_id, system__label_template, system__default_location_attribute_id
from
    working.class;

insert into cm.association(
        id, class_model_id, source_class_id, target_class_id, identifier, label, inverse_identifier, inverse_label, constraint__multiplicity, definition, editorial_note, rdf_match, see_also, constraints, system__type_id
    )
select
    id, class_model_id, source_class_id, target_class_id, identifier, label, inverse_identifier, inverse_label, constraint__multiplicity, definition, editorial_note, rdf_match, see_also, constraints, system__type_id
from
    working.association;

insert into cm.attribute(
    id, class_model_id, identifier, data_type_id, abstract, derived, label, definition, editorial_note, rdf_match, see_also, constraints, system__type_id
)
select
    id, class_model_id, identifier, data_type_id, abstract, derived, label, definition, editorial_note, rdf_match, see_also, constraints, system__type_id
from
    working.attribute;

insert into cm.attribute__domain(
    id, attribute_id, class_id, constraint__multiplicity, constraint__value_collection_id, constraint__value_unit_collection_id, constraint__procedure_collection_id, constraint__agent_collection_id
)
select
    id, attribute_id, class_id, constraint__multiplicity, constraint__value_collection_id, constraint__value_unit_collection_id, constraint__procedure_collection_id, constraint__agent_collection_id
from
    working.attribute__domain ad
where exists(
        select from
            working.attribute a
        where
            ad.attribute_id = a.id
    );