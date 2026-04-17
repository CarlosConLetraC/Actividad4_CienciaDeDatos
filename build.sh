#!/usr/bin/env bash

ls entorno/ > /dev/null 2>&1
ENTORNO_DEFINIDO=$?
set -e

if ! command -v java &> /dev/null || ! command -v luajit &>/dev/null || [ "$ENTORNO_DEFINIDO" -ne 0 ]; then
    ./configurarentorno.sh
fi

javac backend.java