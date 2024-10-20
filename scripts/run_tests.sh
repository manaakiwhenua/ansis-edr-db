#!/usr/bin/env bash

# Runs all pgTAP tests and exits
# This script will install the pgtap extension
# To be run inside Docker

CREATE_PGTAG="CREATE EXTENSION IF NOT EXISTS pgtap;"
echo "Running $CREATE_PGTAG"
psql edr -c "$CREATE_PGTAG"

echo "Running tests"
pushd /opt/edr-dme-db/tests || exit 1
  pg_prove --dbname="edr" --failures  -r ./*.sql ./**/*.sql
popd || exit
