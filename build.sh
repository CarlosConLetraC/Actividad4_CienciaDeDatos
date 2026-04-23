#!/usr/bin/env bash
set -euo pipefail

ls entorno/ > /dev/null 2>&1 || ENTORNO_DEFINIDO=$?
if ! command -v luajit &>/dev/null || [ "$ENTORNO_DEFINIDO" -ne 0 ]; then
    ./configurarentorno.sh
fi

echo "Compilando backend. . ."
#g++ -std=c++17 backend.cpp -Ilibbackend -o backend -lpthread
g++ -std=c++17 backend.cpp -o backend -lpthread