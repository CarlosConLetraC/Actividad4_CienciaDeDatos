ESTE PROYECTO ESTA BASADO EN OTRO PROYECTO DEL MISMO AUTOR: `https://github.com/CarlosConLetraC/Moduler/`. A CONTINUACIÓN ENCONTRARÁ EL MANUAL DEL PROYECTO ORIGINAL.
# Moduler

Moduler es un **motor de ejecución multitenencia de scripts LuaJIT**, diseñado para ejecutar múltiples programas aislados en paralelo, cada uno con su propio entorno (lua-env).

## Arquitectura

Moduler está dividido en dos capas principales:

### Backend (Java)
- Orquesta múltiples instancias de LuaJIT
- Ejecuta `program.*.lua` como procesos aislados
- Administra el ciclo de vida de cada entorno
- Garantiza separación entre contenedores de ejecución

### Runtime (LuaJIT)
Cada programa Lua se ejecuta en un entorno aislado con:
- Sistema de importación modular (`import/`)
- Librerías estándar extendidas (Table, File, JSON, CSV, etc.)
- Acceso controlado a sistema y filesystem
- Herramientas para procesamiento de datos y scripting

## Características

- Ejecución concurrente de múltiples scripts Lua
- Entornos completamente aislados por programa
- Sistema modular de librerías
- Pipeline de datos integrado (CSV/JSON)
- Abstracción de sistema operativo vía Lua

## Casos de uso

- Sandboxing de scripts Lua
- Procesamiento de datos paralelo
- Sistemas de simulación multi-agente
- Prototipado de runtimes personalizados
- Investigación en motores de scripting

## Sistemas compatibles

- Debian 13 (Trixie)
- Ubuntu 22.04 (Jammy)

## Instalación

```bash
git clone --recursive https://github.com/CarlosConLetraC/Actividad3_CienciaDeDatos.git
cd Actividad3_CienciaDeDatos
chmod +x cmd initconsole runclient *.sh
```

## Configurar
```bash
./configurarentorno.sh
```

## Compilar
```bash
./build.sh
```

## Ejecutar
```bash
./run.sh
```
