-- drop view if exists cm.class__associations cascade;
create or replace view cm.class__associations as
    select
        c.class_model_id,
        c.id as class_id,
        c.identifier as class_identifier,
        a.id as association_id,
        a.identifier as association_identifier,
        a.constraint__multiplicity,
        a.label,
        a.bidirectional,
        a.inverse_identifier,
        a.inverse_label,
        a.definition,
        a.editorial_note,
        a.see_also,
        a.constraints,
        a.system__type_id
    from
        cm.class c
            join cm.association a
                on c.id = a.source_class_id;
alter view cm.class__associations owner to edr_wheel;
grant select on table cm.class__associations to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view cm.class__associations
    is 'Shows all attributes of a class, including those inherited from super classes.';
comment on column cm.class__associations.class_model_id
    is 'Class model UUID.';
comment on column cm.class__associations.class_id
    is 'Class UUID.';
comment on column cm.class__associations.class_identifier
    is 'The formal human-readable text identifier for the class. Will be used a JSON key names or derived database table names. Format: UpperCamelCase.';
comment on column cm.class__associations.constraint__multiplicity
    is 'A two element array specifying the minimum and maximum allowable number of association type values for a specific class. This may vary between classes.';
comment on column cm.class__associations.association_id
    is 'Association UUID.';
comment on column cm.class__associations.association_identifier
    is 'The formal human-readable text identifier for the association type. Will be used a JSON key names or derived database column names. Format: lowerCamelCase';
comment on column cm.class__associations.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.class__associations.bidirectional
    is '`true` if the association is bi-directional (has an inverse_id). Generated.';
comment on column cm.class__associations.inverse_identifier
    is 'The inverse association type identifier.';
comment on column cm.class__associations.inverse_label
    is 'A human-friendly label for the association type''s inverse association type (for bi-directional associations where the association is consistently specified in one direction only).';
comment on column cm.class__associations.definition
    is 'A brief definition of the association type. Content may be formatted using Markdown syntax';
comment on column cm.class__associations.editorial_note
    is 'Notes on issues with the association type and any changes that may be required.';
comment on column cm.class__associations.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this association type.';
comment on column cm.class__associations.constraints
    is 'The default constraints on the value of an instance of a association_type. Managed as a JSON object as applicable constraints vary with the association type''s range.';
comment on column cm.class__associations.system__type_id
    is 'The system level type of the association. This cannot be changed once the attribute is referenced by `data.*_aggregation|association` tables.';