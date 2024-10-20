# Datastore - Design principles

### Performance
Performance is a secondary concern. It is considered wherever possible, but not at the expense of
data descriptions and quality. For example, a check constraint that helps ensure erroneous data are
not entered, but comes at a cost to `insert` times, will be tolerated. High-performance access will
be supported by things like materialized views in the database, or caching in the service or client
layers.

### Entity-Attribute-Value structure
The data schema uses an [entity-attribute-value (EAV)](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)
structure. EAV databases tend to make sensible data engineers froth at the mouth with rage but their
use is considered acceptable in this context as the datastore is used to store environmental
[*observations*](https://www.w3.org/TR/vocab-ssn/#Observations).

* Observation records require metadata about their quality (uncertainty) and the procedures used to
make them. Each attribute value is a record in a table so columns for these data can be added.
* The EAV structure is appropriate where many properties of a class may be observed, but each
individual description of a class may only record values for a small subset of these properties.
* It supports support flexibility of data models - new classes and properties are added to tables in
the `cm` schema without requiring structural changes to the `data` schema.

> Note that EAV is not used in the `cm`, `voc` and `sys` schema as it offers no benefits.
> These schema govern the behaviour of the rest of the database so an explicit model with strictly
> governed content is important.

### Naming conventions
Postgres is case insensitive so all element names are lower case. Words in names are separated by an
underscore ('_'). When presented via an API (e.g. as JSON or XML), underscores are removed and names
are converted to UpperCamelCase (tables and views) or lowerCamelCase (property/column names). If an
underscore is required in a JSON/XML name use a double underscore in the database name (e.g.
table_name__suffix -> TableName_Suffix). Double underscores can help (often but not always) group
tables with related/subordinate tables.

Parts of names are ordered so that things of the same type/class are grouped together when
alphabetically ordered. This means names may not be 'naturally' correct because an adjective gets
appended to a name (e.g. `entity_attribute__view`) but it makes exploring the database easier.

> Natural names and labels are encouraged in data products and the presentation layer. These can,
> and should,nbe agreed with the product or interface's target users.

> Rules are made to be broken, so if a variation on this pattern results in a more sensible
> organisation of the database go with the variation.

Element specific conventions are as follows:

| Element                | Template                                                                         | Comments                                                                                              |
|------------------------|----------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| table/column           | {name}\_\_{disambiguator}                                                        |
| foreign key column     | {target-table name}\_\_{target column name}                                      | Multi-column keys may modify the target column name to a summary name.                                |
| primary key constraint | pk\_{table-name}                                                                 |
| foreign key constraint | fk\_{table-name}\_\_{column-name}\_\_{target-table-name}\_\_{target-column-name} | Multi-column keys may modify the source and target column names to a summary name.                    |
| check constraint       | ck\_{table-name}\_\_{column-name}                                                |
| unique constraint      | uq\_{table-name}\_\_{column-name}                                                | Multi-column constraints may modify column names to a summary name.                                   |
| index                  | ix\_{table-name}\_\_{column-name}                                                | Multi-column indexes may modify column names to a summary name.                                       |
| index - foreign key    | fx\_{foreign-key-name}                                                           | A foreign key index should have the same name as the related foreign key (except for the fx_) prefix. |
| index - spatial        | sx\_{table-name}\_\_{column-name}                                                | PostGIS-supported spatial index. Multi-column indexes may modify column names to a summary name.      |

### System columns
Columns prefixed with `system__` are used to manage data: e.g referential integrity and transaction
information. They do not carry any information about the subject of the table itself.

> By convention, these columns are placed at the the end of the column list. This may change if it
> becomes necessary to save space by properly ordering columns based on
> [PgSQLs natural storage alignment](https://www.2ndquadrant.com/en/blog/on-rocks-and-sand/).

### System types
Most things in the `data` schema are typed according to classes, properties and relationships
defined in the `cm` schema. These types (e.g. `class` or `property`) have a `system__type` that ties
them to a basic model for classes, properties and relationships that governs their fundamental
behaviour. This is particularly important for properties and relationships. For example:

* Whether a class is a `dataset` or an `entity` (or sub-type thereof) determines whether they are
stored in ... the `dataset` or `entity` tables.
* For attributes, their system type will determine how much metadata they need and therefore what
table they are stored in. For example an `assertion` does not have a procedure or quality, an
`observation` has simple procedure and quality values described using concepts, while a
`measurement` will have complex structured procedure and quality descriptions.
* For associations, an `aggregation` means the related entity must be deleted along with the source
feature while entities in an `relationship` can exist independently.
* Relationship tables may be split in two to enforce the above, e.g. `entity__aggregation` and
`entity__relationship`.
* Allowable `system__types` for a table are managed using check constraints.

#### System type definition tables
* `system__type__class_model`
* `system__type__class`
* `system__type__association`
* `system__type__attribute`
* `system__type__data_type`

### JSONB columns
JSONB is used columns are used for columns that have polymorphic data types. This could be because:

* the value structure varies with context - e.g. `cm.attribute.constraints` will differ between a
numeric value and a categorical one.
* the value is in an EAV property table - value data types will vary with properties
* in some cases (e.g. a quantity with unit of measure or a Munsell colour value) is best handled
using a structured object.

### Primary key implementation
All ID values are [UUIDs](https://www.postgresql.org/docs/current/datatype-uuid.html). For primary
keys, these are generated by default using `gen_random_uuid()`. Client tools may generate their own
UUIDs, provided they are correctly formatted (PgSQL will reject them if not). See previous link for
details of UUID format variations PgSQL will tolerate.

> An exception has been made for identifiers for certain fundamental things (`*_system__type` and
> `concept_relationship`). These get human-readable strings for the traditional no good reason
> beyond making it easy to make them consistent across all database instances and easy to recognise
> when the database is being ... hacked.

> Something like a [ULID](https://victoryosayi.medium.com/ulid-universally-unique-lexicographically-sortable-identifier-d75c253bc6a8)
> could be nice, but clients are guaranteed to be able to generate them. Also, temporal ordering of
> records may not be meaningful, for example historical data may be added at the same time as active
> surveys.

Primary keys are always called `id`, unless they are not (e.g. composite keys):

* all class tables and their attribute and association tables have a single `id` primary key.
* attribute and association `ids` make it easier to track the history of values in system versioning
tables.

### Foreign key implementation
Foreign keys are implemented as per PgSQL requirements. By default referential integrity enforces
cascading deletes and updates. In some cases, however, deletes are restricted if instance specific
logic dictates whether a foreign relation should be deleted, or perhaps associated with a different
entity before the primary entity is deleted.

### Constraint deferral
All referential integrity constraints are deferrable by default. Most transactions modifying the
database will be sending a collection of related classes (essentially a graph) in a single batch.
Deferring enforcement of referential integrity until the whole graph is loaded will made the CrUD
operation easier to sequence.

### Indexing
There is no formal indexing strategy for the database, but we've done our best to consider best
practices when creating indexes (column order etc). The following indexes are created by default to
support table joining and searches:

* primary key indexes (automatically created by PgSQL)
* foreign key indexes (single/multi-column indexes on columns participating in a foreign key)
* property values - GIST indexes as these values are stored in JSONB objects
* default values on class tables (e.g. `entity.default_geometry`) - to support searches

> MWLR is experimenting with the use of `includes` in some foreign key indexes on relation
> tables. Ideally it means that values that may be used to label links (e.g. default_label) are
> stored on the index. Saves the execution of a join in some cases. Maybe.

> `pg_trgm` trigram indexes are being trialled on `default_label` columns as most searches on those
> columns will use wildcards.
>
> `default_location` columns are indexed using PostGIS GIST indexes.

### Generated columns
[Generated columns](https://www.postgresql.org/docs/14/ddl-generated-columns.html) have been used
for formatted labels and URIs as their values are consistently generated from other values. In some
cases PL/PgSQL functions are used to generate values as some required values are stored in other
tables (generated columns can only reference values in their own table).

### Period data types
[Range data types](https://www.postgresql.org/docs/current/rangetypes.html) have been used for range
values because ... it is interesting to see how well these work. The assumption is that there will
be quite a few topological queries against these values (e.g. time overlaps) that are better handled
using range data-types and functions.

### Database documentation
All database documentation is generated from the PGSQL catalog and comments on tables, columns, etc.
This is captured in the `doc_` prefixed views in the `sys` schema and are aggregated into markdown
documents in the view `sys.doc_markdown`.

This is to ensure that the database is fully described in itself and definitions are available to
any user with database access and/or a database IDE.

Markdown docs will assume that they are published according to the MWLR GitHub best practice:

* markdown files in a folder ./doc
* ERD diagrams (images) in a folder ./figs

> Contemplating storing DB ERD diagrams as BLOBs (gulp) in the DB.