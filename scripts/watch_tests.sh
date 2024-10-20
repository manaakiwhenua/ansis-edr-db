#!/bin/bash

# Execute run_tests.sh whenever a file in tests/ changes
# To be run inside Docker

pushd /opt/edr-dme-db || exit 1
  ./scripts/run_tests.sh

  while true; do
    change=$(inotifywait -r -e close_write,moved_to,create ./tests)
    if [ "$change" ]; then
      echo "Tests changed!"
      ./scripts/run_tests.sh
    fi
  done
popd
