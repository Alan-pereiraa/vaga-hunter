#!/bin/sh
# Roda só na primeira inicialização do volume do Postgres.
# Instala o pgvector no template1 (todo banco novo herda a extensão, inclusive
# o "shadow database" do `prisma migrate dev`) e no banco da aplicação.
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname template1 -c 'CREATE EXTENSION IF NOT EXISTS vector;'
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c 'CREATE EXTENSION IF NOT EXISTS vector;'
