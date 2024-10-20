-- drop view if exists cm.attribute__view cascade;
create or replace view cm.attribute__view as
    with _attribute__domain as (
            select
                pd.attribute_id,
                max(cm.identifier) as defined_by,
                array_agg(
                    distinct
                    dct.identifier
                ) as domain_includes
            from
                cm.attribute__domain pd
                    left join cm.class dct on pd.class_id = dct.id
                    left join cm.class_model cm on dct.class_model_id = cm.id
            group by
                pd.attribute_id
        )
    select
        p.id,
        p.identifier,
        dt.label as data_type,
        st.label as system__type,
        p.derived,
        p.label,
        p.definition,
        pd.defined_by,
        pd.domain_includes,
        p.see_also,
        p.constraints
    from
        cm.attribute p
            left join cm.class_model cm on p.class_model_id = cm.id
            left join cm.system__type__attribute st on p.system__type_id = st.id
            left join cm.system__type__data_type dt on p.data_type_id = dt.id
            left join _attribute__domain pd on p.id = pd.attribute_id;
alter view cm.attribute__view owner to edr_wheel;
grant select on table cm.attribute__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view cm.attribute__view
    is 'Human friendly view of cm.attribute. Gets labels for UUIDs and aggregates labels of associated entities into arrays.';
comment on column cm.attribute__view.id
    is 'Attribute UUID.';
comment on column cm.attribute__view.identifier
    is 'The formal human-readable text identifier for the attribute type. Will be used as JSON key names or derived database column names. Format: lowerCamelCase.';
comment on column cm.attribute__view.system__type
    is 'The system level type of the attribute.';
comment on column cm.attribute__view.derived
    is 'Specifies whether the attribute is concrete (false - default) or derived (true). Derived properties are a function of one or more concrete attribute types.';
comment on column cm.attribute__view.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.attribute__view.definition
    is 'A brief definition of the attribute type. Content may be formatted using Markdown syntax.';
comment on column cm.attribute__view.defined_by
    is 'The class model this attribute belongs to.';
comment on column cm.attribute__view.domain_includes
    is 'Array of classes this attribute is an attribute of.';
comment on column cm.attribute__view.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this attribute type.';
comment on column cm.attribute__view.constraints
    is 'The default constraints on the value of an instance of a attribute. Managed as a JSON object as applicable constraints vary with the attribute type''s range.';