#!/usr/bin/env bash

set -e

if [ "$ANSIS_INIT_DATABASE" -eq 1 ]; then
  pushd /opt/ansis/code || exit 1
    ./build.sh
  popd || exit
fi
