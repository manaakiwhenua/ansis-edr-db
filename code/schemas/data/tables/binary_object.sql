-- drop table if exists data.binary_object cascade;
create table data.binary_object (
        id text generated always as (md5(blobject)) stored,
        blobject bytea not null,
        media_type text not null,
        file_extension text null,
        content_encoding text null,
	    constraint pk_binary_object primary key (id)
    );
alter table data.binary_object owner to edr_wheel;
grant insert, update, delete on table data.binary_object to edr_admin, edr_jwt, edr_edit;
grant truncate on table data.binary_object to edr_admin;
grant select on table data.binary_object to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table data.binary_object
	is 'A binary object store for photos and scanned documents, and raw output from sensors (e.g. spectrometers). Binary objects are linked to a entity/dataset via a key in the xxx_attribute.value JSON object (see the `binary-object` data type in cm.system__type__data_type). Only one copy of a binary object is to be stored, it may be shared (e.g. a photo of multiple sites) by several entities. Objects should be stored using media types and content encodings support by HTTP web APIs. File names are managed on each attribute that references the binary object as different names may be appropriate in different circumstances.';
comment on column data.binary_object.id
    is 'Binary Object UUID - generated from the md5 hash of the binary object. Allows clients to create objects and refer to them when offline or before the object has been created server-side. Also ensures an object is only stored once.';
comment on column data.binary_object.blobject
    is 'The binary object.';
comment on column data.binary_object.media_type
    is 'The media type (AKA MIME Type) of the binary object. Values are as defined by the Internet Assigned Numbers Authority (IANA): https://www.iana.org/assignments/media-types/media-types.xhtml.';
comment on column data.binary_object.file_extension
    is 'The well-known file extension appropriate to the object if it is downloaded as a file.';
comment on column data.binary_object.content_encoding
    is 'The file compression algorithm used, if applicable. Values are as defined by the Internet Assigned Numbers Authority (IANA) for content encodings returned in the HTTP Accept-Encoding header: https://www.iana.org/assignments/http-parameters/http-parameters.xml#content-coding.';