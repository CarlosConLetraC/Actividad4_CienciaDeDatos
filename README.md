## Casos de uso implementados

- Actividad 4: Ciencia de datos sobre dataset de autos  
Ver documentación en `ACTIVIDAD4_parte1.md`

---

ESTE PROYECTO ESTA BASADO EN OTRO PROYECTO DEL MISMO AUTOR:  
https://github.com/CarlosConLetraC/Moduler/

A CONTINUACIÓN SE DOCUMENTA LA VERSIÓN ACTUALIZADA DEL SISTEMA.

# Moduler (Actividad 4 - Ciencia de Datos)

Moduler es un **motor de ejecución concurrente de jobs basado en LuaJIT
y C++**, diseñado para procesar tareas de ciencia de datos de forma
paralela mediante un scheduler propio, un thread pool interno y un
sistema de ejecución aislada por scripts.

El sistema integra un pipeline completo que incluye: - ejecución
concurrente de jobs - procesamiento de datos - entrenamiento de modelos
de machine learning ligeros - exportación de resultados en JSON -
análisis posterior en Python

------------------------------------------------------------------------

# Arquitectura general

El sistema está dividido en cuatro capas principales:

## Backend en C++ (núcleo del sistema)

Ubicado en: backend.cpp libbackend/

Componentes principales: - Scheduler: gestión de jobs pendientes y
prioridades - Broker: distribución de jobs entre workers - ThreadPool:
ejecución concurrente controlada - Worker: ejecución de scripts LuaJIT
aislados

------------------------------------------------------------------------

## Librerías de Machine Learning y datos (C/C++)

Ubicado en: cpplibs/ clibs/

-   cml.cpp → regresión logística y modelo lineal básico
-   csvfast.cpp → parser optimizado de CSV
-   cstats.c → estadísticas

------------------------------------------------------------------------

## Runtime LuaJIT

Ubicado en: import/

Extiende LuaJIT con: - JSON parser - CSV utilities - system bridge -
vectores y matemáticas - sistema de tareas

------------------------------------------------------------------------

## Pipeline de ejecución

Scripts principales: program.actividad4_parte1.lua
program.actividad4_parte2.lua preworker.lua

Flujo: 1. creación de jobs 2. scheduling en backend C++ 3. ejecución en
workers LuaJIT 4. generación de métricas 5. exportación JSON 6. análisis
en Python

------------------------------------------------------------------------

# Características

-   ejecución concurrente de jobs
-   scheduler con colas
-   thread pool en C++
-   aislamiento por proceso LuaJIT
-   retry system con backoff
-   pipeline de ML embebido

------------------------------------------------------------------------

# Casos de uso

-   procesamiento paralelo de datasets
-   entrenamiento de modelos de ML
-   análisis de rendimiento por worker
-   simulación de pipelines de datos

------------------------------------------------------------------------

# Nota importante

El sistema es concurrente local, NO distribuido en red.