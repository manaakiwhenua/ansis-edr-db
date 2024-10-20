#!/bin/bash

# created (mostly) by fighting with ChatGPT

# repo path - allows use of full paths to avoid any relative path shenanigans in bash.
repo_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P )

# run all subsequent commands in the repo path
pushd "$repo_path" || exit 1;

# CSV file name
manifest_csv="manifest.csv"

# Postgres connection parameters
# Running inside the docker container, this image will use the environment variables
# set out in the postgres docker image docs - https://hub.docker.com/_/postgres
# or the libpq docs https://www.postgresql.org/docs/current/libpq-envars.html

# Loop through each line in the CSV file - tail starts the file read on the second line
# -- ensures the column header row is ignored
tail -n +2 "$manifest_csv" | while IFS=',' read -r database path file;
do
    # make sure the file name from the CSV doesn't include trailing spaces/carriage returns
    file_name=$(echo "$file" | tr -d '[:space:]')

    # Concatenate repo path, local path from csv, and file_name to form the relative path of the SQL script file
    if [ -n "$path" ]; then
        sql_script="${path}/${file_name}"
    else
        sql_script="${file_name}"
    fi

    echo "-- [$database] running :$sql_script"

    # Check if the SQL script file exists
    if [ ! -f "$sql_script" ]; then
        echo "== SQL script file not found:"
        echo "==     $sql_script"
        echo "== Debug:"
        # List path and script to force (possibly) useful error reports
        ls -l "$repo_path$path"
        ls "$sql_script"
        exit
    fi

    # PostgreSQL command to execute the SQL script file
    if ! psql -q -d "$database" -f "$sql_script"
    then
      # Handle errors, if any
      echo "== Error executing psql command for SQL script file:"
      echo "==     $sql_script"
      exit # Do we want to exit with an error code?
    else
      echo "-- OK"
    fi
done
