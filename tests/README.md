# pgTAP unit tests

Unit tests are written with [pgTAP](https://pgtap.org/) and are stored in this directory.

## Running pgTAP unit tests

To run the tests:
- start the dbms in Docker container
- execute `scripts/run_tests.sh` to run once, or `scripts/watch_tests.sh` to run tests whenever files in `tests/` change
  For example, assuming the service is run with `docker compose`

```shell
docker compose exec -u postgres -w /opt/edr-dme-db dbms ./scripts/run_tests.sh
docker compose exec -u postgres -w /opt/edr-dme-db dbms ./scripts/watch_tests.sh
```
