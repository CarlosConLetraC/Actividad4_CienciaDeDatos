#!/usr/bin/env bash
set -e

ls entorno/ > /dev/null 2>&1
ENTORNO_DEFINIDO=$?

if ! command -v luajit &>/dev/null || [ "$ENTORNO_DEFINIDO" -ne 0 ]; then
    ./configurarentorno.sh
fi

echo "Compilando backend C++ (header-only). . ."
#g++ -std=c++17 backend.cpp -Ilibbackend -o backend -lpthread
g++ -std=c++17 backend.cpp -o backend -lpthread