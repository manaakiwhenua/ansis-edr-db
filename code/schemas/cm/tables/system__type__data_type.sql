-- drop table if exists cm.system__type__data_type cascade;
create table cm.system__type__data_type (
	    id text not null,
	    identifier text not null,
        abstract boolean default false not null,
	    label text null,
        definition text null,
	    schema_json jsonb null,
	    pgsql_cast text null,
	    pgsql_select_expression jsonb null,
        super_type_id text null,
	    constraint pk_system__type__data_type
	        primary key (id),
	    constraint uq_system__type__data_type__identifier
	        unique (identifier),
	    constraint fk_system__type__data_type__super_type
            foreign key (super_type_id) references cm.system__type__data_type(id)
            deferrable initially deferred
	);
alter table cm.system__type__data_type owner to edr_wheel;
grant select on table cm.system__type__data_type to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.system__type__data_type
    is 'Definitions of the JSON data types used for attribute values. Includes JSON schema definitions.';
comment on column cm.system__type__data_type.id
    is 'The system type id.';
comment on column cm.system__type__data_type.identifier
    is 'The formal human-readable text identifier for the data type. Used for consistency with class types.';
comment on column cm.system__type__data_type.abstract
    is 'Specifies whether the data type is concrete (false - default) or abstract (true). Instances of abstract data types cannot be created.';
comment on column cm.system__type__data_type.label
    is 'A human-friendly label for the system type.';
comment on column cm.system__type__data_type.definition
    is 'A brief definition of the system type. Content may be formatted using Markdown syntax.';
comment on column cm.system__type__data_type.schema_json
    is 'The JSON Schema defining the structure of the value when stored as an object in an attribute table.';
comment on column cm.system__type__data_type.pgsql_cast
    is 'The PgSQL cast string to be added to a value in a select statement when extracted from a JSON object as text, e.g. `::numeric(5,2)` for `(value ->> ''.'')::numeric(5,2)`.';
comment on column cm.system__type__data_type.pgsql_select_expression
    is 'Templates for casting JSONB attribute values in SQL `SELECT` expressions. Is a JSON object to allow for separate templates for object value keys. Can be used as helpful templates when writing SQL queries or be embedded in execute format() statements in functions. The alias is to be replaced with the ... alias (e.g. `xx.`) ... or an empty string.';
comment on column cm.system__type__data_type.super_type_id
    is 'The super (parent) system type id where a type specialises another.';
comment on constraint uq_system__type__data_type__identifier on cm.system__type__data_type
    is 'Ensures that the data type identifier is unique.';