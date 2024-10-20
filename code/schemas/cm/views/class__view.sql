-- drop view if exists cm.class__view cascade;
create or replace view cm.class__view as
    with _class__specialisation as (
            select
                cs.class_id,
                array_agg(
                    rc.identifier
                    order by rc.identifier
                ) as sub_classes
            from
                cm.class__specialisation cs
                    left join cm.class rc on cs.sub_class_id = rc.id
            group by
                cs.class_id
        ),
        _attribute__domain as (
            select
                pd.class_id,
                array_agg(
                    concat(
                        p.identifier,
                        ' [',
                        pd.constraint__multiplicity[1]::text,
                        '..',
                        coalesce(
                            pd.constraint__multiplicity[2]::text,
                            '*'
                        ),
                        ']'
                    )
                    order by
                        concat(
                            p.identifier,
                            ' [',
                            pd.constraint__multiplicity[1]::text,
                            '..',
                            coalesce(
                                pd.constraint__multiplicity[2]::text,
                                '*'
                            ),
                            ']'
                        )
                ) as properties
            from
                cm.attribute__domain pd
                    left join cm.attribute as p on pd.attribute_id = p.id
            group by
                pd.class_id
        ),
        _association__range as (
            select
                rr.source_class_id as class_id,
                array_agg(
                    rrr.identifier
                    order by rrr.identifier
                ) as range_of
            from
                cm.association rr
                    join cm.class rrr
                        on rr.target_class_id = rrr.id
            group by
                rr.source_class_id
        )
    select
        c.id,
        c.identifier,
        st.label as system__type,
        c.abstract,
        c.label,
        c.definition,
        cm.identifier as defined_by,
        cs.sub_classes,
        pd.properties,
        rr.range_of,
        c.see_also
    from
        cm.class c
            left join cm.class_model cm on c.class_model_id = cm.id
            left join cm.system__type__class st on c.system__type_id = st.id
            left join _class__specialisation cs on c.id = cs.class_id
            left join _attribute__domain pd on c.id = pd.class_id
            left join _association__range rr on c.id = rr.class_id;
alter view cm.class__view owner to edr_wheel;
grant select on table cm.class__view to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view cm.class__view
    is 'Human friendly view of cm.class. Gets labels for UUIDs and aggregates labels of associated entities into arrays.';
comment on column cm.class__view.id
    is 'Class UUID.';
comment on column cm.class__view.identifier
    is 'The formal human-readable text identifier for the class. Will be used a JSON key names or derived database table names. Format: UpperCamelCase.';
comment on column cm.class__view.system__type
    is 'The system level type of the class.';
comment on column cm.class__view.abstract
    is 'Specifies whether the class is concrete (false - default) or abstract (true). Instances of abstract classes cannot be created.';
comment on column cm.class__view.label
    is ' A formatted label for presentation in documentation or user interfaces. Format: Proper Noun.';
comment on column cm.class__view.definition
    is 'A brief definition of the class type. Content may be formatted using Markdown syntax.';
comment on column cm.class__view.defined_by
    is 'The class model this class belongs to.';
comment on column cm.class__view.sub_classes
    is 'Array of sub classes of this class.';
comment on column cm.class__view.properties
    is 'Array of the properties of this class.';
comment on column cm.class__view.range_of
    is 'Array of the associations of this class is the range (value) of.';
comment on column cm.class__view.see_also
    is 'An array of URLs for web pages or other web resources that describe or define this class type.';