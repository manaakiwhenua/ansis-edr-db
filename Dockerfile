FROM postgres:16-bullseye

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV PG_MAJOR=16
ENV POSTGIS_MAJOR=3

# Install postgresql extensions and python
RUN apt update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
           postgresql-$PG_MAJOR-cron \
           vim \
           postgresql-$PG_MAJOR-h3 \
           python3 pip \
           postgresql-plpython3-$PG_MAJOR \
           pgtap \
           postgresql-16-pgtap \
           inotify-tools \
    && rm -rf /var/lib/apt/lists/*

RUN pip install jsonschema

# Initialise the EDR DB and PostGIS
RUN mkdir -p /docker-entrypoint-initdb.d

COPY --link ./docker/pgsql/initdb-edr.sh /docker-entrypoint-initdb.d/edr.sh
COPY --link ./docker/pgsql/update-postgis.sh /usr/local/bin

COPY --link ./code /opt/ansis/code
COPY --link ./data /opt/ansis/data
COPY --link ./scripts /opt/ansis/scripts
COPY --link ./tests /opt/ansis/tests
