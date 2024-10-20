# Soil Data Repository Datastore

## Background

DDL for a soil data repository database.

Documentation of this database, including the basic principles governing the design of the
datastore, are described in [the README document in the docs folder](docs/README.md).

> See the [code folder READ ME file](./code/README.md) for instructions on building a new,
> empty instance of the database.

## Docker Container

A Docker Container hosting the database can be created using Docker Compose. Before running Docker
Compose __please read the docker folder [README](./docker/README.md)__ as it documents the
creation of environment files necessary to create the container. If these are not created, the
container won't start.

### Requirements

 - Docker

### Running

Use docker compose command to run the project

```shell
docker compose build
docker compose up
```

## Repository Content
| What                                                                  | Where                  |
|-----------------------------------------------------------------------|------------------------|
| PostgreSQL DDL                                                        | [./code](./code)       |
| Test data                                                             | [./data](./data)       |
| EDR PostgreSQL Docker Container                                      | [./docker](./docker)   |
| Database documentation and definitions                                | [./docs](./docs)       |
| Figures for database documentation                                    | [./figs](./figs)       |
| pgTAP unit tests                                                      | [./tests](./tests)     |
| Helper scripts                                                        | [./scripts](./scripts) |
