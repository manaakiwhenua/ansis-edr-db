-- drop table if exists data.entity__default_location cascade;
create table data.entity__default_location (
        entity_id uuid default gen_random_uuid() not null,
        location geometry(point,4326) not null,
        constraint pk_entity__default_location primary key (entity_id),
        constraint fk_entity__default_location__entity foreign key (entity_id)
            references data.entity (id)
            on delete cascade on update cascade
            deferrable initially deferred
    );
create index if not exists sx_entity__default_location__location on data.entity__default_location using gist (location);
alter table data.entity__default_location owner to edr_wheel;
grant select on table data.entity__default_location to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.entity__default_location
    is 'The default location (the point, or a centroid for lines or polygons) for an entity when displayed and searched (including spatial joins). Stored as a WGS84 (EPSG:4326) lat/long geometry. Derived from the most accurate location in `data.entity__assertion|observation|measurement` - populated by a trigger function. Extends `data.entity` as not all entities have a spatial extent.';
comment on column data.entity__default_location.entity_id
    is 'Entity UUID.';
comment on column data.entity__default_location.location
    is 'The default point location at the surface. This is the centroid of an entity with an areal extent.';