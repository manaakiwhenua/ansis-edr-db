# ANSIS -  EAV PostgreSQL Data Definition Language (DDL) Scripts

This folder holds Data Definition Language (DDL) scripts for the `edr` database.
It is organised along the same lines as the Microsoft Visual Studio
[SQL Server Data Tools](https://learn.microsoft.com/en-us/sql/ssdt/sql-server-data-tools).

The DDL statements for each database element are stored and managed as individual files organised into
folders as follows.

| Path     | Description                                                                                                      |
|----------|------------------------------------------------------------------------------------------------------------------|
| .        | SQL files that create (`create.sql`) the database and initialise its extensions (`extensions.sql`).              |
| schemas  | DDL for `functions`, `tables`, `triggers` and `views` for each schema.                                           |
| security | DDL for Row Level Security `policies`, `schema` creation, and `users` (permissions and role memberships).        |
| types    | DDL for any user-defined PostgreSQL [`data types`](https://www.postgresql.org/docs/current/sql-createtype.html). |

The database is built by a bash script (`build.sh`) the executes each individual DDL files in order
according to the file `manifest.sql`. The ordering of the manifest ensures that elements that may be 
required by other elements are created first (the may included creating elements in other schemas first).

The build script loops through the manifest to run a psql statement for each DDL file. The manifest
specifies which database the script is to be run against (e.g. the `postgres` maintenance database for
the `create database` statement), the path to the script and its file name.

Records for new scripts must be added in the appropriate part of the manifest for a new instance of the
database to initialise using that script.