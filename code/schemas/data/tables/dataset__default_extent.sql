-- drop table if exists data.dataset__default_extent cascade;
create table data.dataset__default_extent (
        dataset_id uuid not null,
        extent geometry(polygon,4326) not null,
        constraint pk_dataset__default_extent primary key (dataset_id),
        constraint fk_dataset__default_extent__dataset foreign key (dataset_id)
            references data.dataset (id)
            on delete cascade on update cascade
            deferrable initially deferred
    );
create index if not exists sx_dataset__default_extent__extent on data.dataset__default_extent using gist (extent);
alter table data.dataset__default_extent owner to edr_wheel;
grant select on table data.dataset__default_extent to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.dataset__default_extent
    is 'The default extent for an dataset when displayed and searched. Stored as a WGS84 (EPSG:4326) lat/long geometry. Derived from a polygon (a concave hull) encompassing the member entity''s default location (`data.entity__default_location`) - populated by a trigger function on `data.entity__default_location`. Extends `data.dataset` as not all datasets have a spatial extent.';
comment on column data.dataset__default_extent.dataset_id
    is 'Dataset UUID.';
comment on column data.dataset__default_extent.extent
    is 'The default extent of the dataset.';