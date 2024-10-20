-- drop view if exists cm.class__attributes cascade;
create or replace view cm.class__attributes as
    select
        c.class_model_id,
        c.id as class_id,
        c.identifier as class_identifier,
        a.id as attribute_id,
        a.identifier as attribute_identifier,
        ad.constraint__multiplicity,
        ad.constraint__value_collection_id,
        ad.constraint__value_unit_collection_id,
        ad.constraint__agent_collection_id,
        ad.constraint__procedure_collection_id,
        a.data_type_id,
        a.derived,
        a.label,
        a.definition,
        a.editorial_note,
        a.see_also,
        a.constraints,
        c.system__type_id as class_system__type_id,
        a.system__type_id as attribute_system__type_id
    from
        cm.class c
            join cm.attribute__domain ad
                on ad.class_id = any(cm.class__super_class(c.id) || c.id)
            join cm.attribute a
                on ad.attribute_id = a.id;
alter view cm.class__attributes owner to edr_wheel;
grant select on table cm.class__attributes to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view cm.class__attributes
    is 'Shows all attributes of a class, including those inherited from super classes.';
comment on column cm.class__attributes.class_model_id
    is 'Class model UUID.';
comment on column cm.class__attributes.class_id
    is 'Class UUID.';
comment on column cm.class__attributes.class_identifier
    is 'The formal human-readable text identifier for the class. Will be used a JSON key names or derived database table names. Format: UpperCamelCase.';
comment on column cm.class__attributes.constraint__multiplicity
    is 'A two element array specifying the minimum and maximum allowable number of association type values for a specific class. This may vary between classes.';
comment on column cm.class__attributes.constraint__value_collection_id
    is 'The UUID of the concept_collection_id that specified the available concepts for concept reference attributes.';
comment on column cm.class__attributes.constraint__value_unit_collection_id
    is 'The UUID of the concept_collection_id that specified the available concepts for quantity unit reference values.';
comment on column cm.class__attributes.constraint__agent_collection_id
    is 'The UUID of the concept_collection_id that specified the available agent entities for agent reference attributes.';
comment on column cm.class__attributes.constraint__procedure_collection_id
    is 'The UUID of the concept_collection_id that specified the available procedure entities for procedure reference attributes.';
comment on column cm.class__attributes.attribute_id
    is 'Attribute UUID.';
comment on column cm.class__attributes.attribute_identifier
    is 'The formal human-readable text identifier for the attribute type. Will be used a JSON key names or derived database column names. Format: lowerCamelCase.';
comment on column cm.class__attributes.data_type_id
    is 'The data type of the attribute. For attributes with polymorphic data types, specialise the attribute by data types.';
comment on column cm.class__attributes.derived
    is 'Specifies whether the attribute is concrete (false - default) or derived (true). Derived properties are a function of one or more concrete attribute types.';
comment on column cm.class__attributes.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.class__attributes.definition
    is 'A brief definition of the attribute type. Content may be formatted using Markdown syntax.';
comment on column cm.class__attributes.editorial_note
    is 'Notes on issues with the attribute type and any changes that may be required.';
comment on column cm.class__attributes.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this attribute type.';
comment on column cm.class__attributes.constraints
    is 'The default constraints on the value of an instance of a attribute. Managed as a JSON object as applicable constraints vary with the attribute type''s range.';
comment on column cm.class__attributes.class_system__type_id
    is 'The system level type of the class.';
comment on column cm.class__attributes.attribute_system__type_id
    is 'The system level type of the attribute.';