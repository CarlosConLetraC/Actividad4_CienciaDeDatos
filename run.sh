#!/usr/bin/env bash
set -euo pipefail

function prettyprint() {
    local level=$1
    shift
    local packed=("$@")

    case $level in
        0)
            printf "\e[0;36m[INFO]:\e[0m %s\n" "${packed[*]}"
        ;;
        1)
            printf "\e[0;33m[WARN]:\e[0m %s\n" "${packed[*]}"
        ;;
        2|*)
            printf "\e[0;31m[FAIL]:\e[0m %s\n" "${packed[*]}"
        ;;
    esac
}

if ! command -v luajit >/dev/null 2>&1; then
    prettyprint 0 "LuaJIT no encontrado"

    if [ ! -d "entorno" ]; then
        prettyprint 0 "creando entorno. . ."
        ./configurarentorno.sh
    else
        prettyprint 0 "entorno existe, intentando actualizar. . ."
        ./configurarentorno.sh
    fi
fi

# if ! command -v luajit >/dev/null 2>&1; then
#     prettyprint 2 "LuaJIT no se encuentra instalado."
#     exit 1
# fi

[ -x ./backend ] || ./build.sh
source "$PWD/entorno/bin/activate"

# PARTE 1
./runclient program.actividad4_parte1.lua
./backend daemons
rm -rf daemons/*
python actividad_parte1.py

# PARTE 2
./runclient program.actividad4_parte2.lua
python actividad_parte2.py