FROM postgres

# Create plpython3u when the db starts.
RUN echo 'CREATE EXTENSION IF NOT EXISTS plpython3u;' > /docker-entrypoint-initdb.d/py3.sql

# Install last python and plpython3 for current version
RUN apt update && apt install -y python3 python3-pip postgresql-plpython3-${PG_MAJOR} postgresql-${PG_MAJOR}-debversion