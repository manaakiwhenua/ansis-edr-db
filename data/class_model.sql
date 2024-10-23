-- drop view if exists working.class_model;
create or replace view working.class_model as
select
    '3908e757-e482-4412-8759-ec6ef969482c' as id,
    '54c83d3f-3314-438f-a5b3-54fd34480bdb' as register_id,
    'ansis' as identifier,
    'https://anzsoil.org/def/au/domain/' as base_uri,
    'ansis' as namespace_prefix,
    'ANSIS Soil Domain Schema' as label,
    'Definitions of the complete list of entities (features in GIS speak) defined in or imported by the ANSIS Domain Ontology.' as description,
    'Generated from ANSIS JSON schema documents.' as editorial_note,
    array['https://anzsoildata.github.io/def-au-schema-json/docs/ansis-schema'] as see_also,
    'edr-physical' as system__type_id;
alter view working.class_model owner to edr_wheel;
grant select on table working.class_model to edr_admin, edr_jwt, edr_edit, edr_read;