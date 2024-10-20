-- drop view if exists	cm.class_model__view cascade;
create or replace view cm.class_model__view as
    select
        cm.id,
        cm.identifier,
        st.label as system__type,
        cm.base_uri,
        cm.namespace_prefix,
        cm.label,
        cm.description,
        array_agg(
            c.identifier
            order by 1
        ) as defines,
        cm.see_also
    from
        cm.class_model cm
            left join cm.system__type__class_model st on cm.system__type_id = st.id
            left join cm.class c on cm.id = c.class_model_id
    group by
        cm.id,
        cm.identifier,
        st.label,
        cm.base_uri,
        cm.namespace_prefix,
        cm.label,
        cm.description,
        cm.see_also,
        cm.system__type_id;
alter view cm.class_model__view owner to edr_wheel;
grant select on table cm.class_model__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view cm.class_model__view
    is 'Human friendly view of cm.class_model. Gets labels for UUIDs and aggregates labels of associated entities into arrays.';
comment on column cm.class_model__view.id
    is 'Class model UUID.';
comment on column cm.class_model__view.identifier
    is 'The formal human-readable text identifier for the class model. Format: UpperCamelCase.';
comment on column cm.class_model__view.system__type
    is 'The system level type of the class model.';
comment on column cm.class_model__view.base_uri
    is 'The base URI identifying (and publishing the model). Is also the path to class and property (attribute and association) types defined in the model.';
comment on column cm.class_model__view.namespace_prefix
    is 'The default namespace prefix to be used in place of the base URI when identifier URIs are abbreviated as compact URIs (CURIs).';
comment on column cm.class_model__view.label
    is 'A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.class_model__view.description
    is 'A brief description of the class model. Content may be formatted using Markdown syntax.';
comment on column cm.class_model__view.defines
    is 'An array of classes defined in this class model.';
comment on column cm.class_model__view.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this class model.';