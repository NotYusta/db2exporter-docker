#!/bin/sh
if [ -z "$DSN" ]; then
    echo "Please set the DSN!"
    exit 1
fi

if [ -z "$DB" ]; then
    echo "Please set the DB!"
    exit 1
fi

ibm_db2_exporter --dsn="$DSN" --db="$DB"
