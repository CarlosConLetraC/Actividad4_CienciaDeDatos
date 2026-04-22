## Casos de uso implementados

- Actividad 4: Ciencia de datos distribuida sobre dataset de autos  
Ver documentación en `ACTIVIDAD4_parte1.md`

---

ESTE PROYECTO ESTA BASADO EN OTRO PROYECTO DEL MISMO AUTOR:  
https://github.com/CarlosConLetraC/Moduler/

A CONTINUACIÓN SE DOCUMENTA LA VERSIÓN ACTUALIZADA DEL SISTEMA.

# Moduler

Moduler es un **motor de ejecución concurrente de scripts LuaJIT con arquitectura tipo scheduler/worker**, diseñado para ejecutar múltiples programas en paralelo con control de colas, prioridades, retries y aislamiento por proceso.

---

## Arquitectura actual

El sistema ha evolucionado a un modelo inspirado en sistemas tipo **Celery / job scheduler distribuido**, dividido en tres capas:

---

### Backend (C++)

El backend ahora es el núcleo del sistema y está implementado en C++.

Responsabilidades:

- Scheduler central con colas:
  - `pending queue`
  - `priority queue (ready)`
  - `delayed retry queue`
- ThreadPool interno para ejecución concurrente
- Dispatcher thread basado en eventos (condition_variable)
- Control de carga (anti storm / rate limiting)
- Sistema de retries con backoff temporal
- Ejecución de scripts LuaJIT mediante `system()`

---

### ThreadPool (C++)

- Pool fijo de workers
- Cola de tareas protegida por mutex
- Ejecución paralela controlada
- Backpressure básico para evitar saturación

---

### Worker (LuaJIT runtime)

Cada job ejecuta un script LuaJIT aislado:

- `luajit -l import/init <script>`
- Procesamiento de datos independiente por job
- Generación de resultados (JSON, logs, métricas)
- Ejecución paralela sin estado compartido

---

## Características

- Ejecución concurrente de scripts LuaJIT
- Scheduler central con prioridad de jobs
- Sistema de retries con delay (backoff simple)
- Control de carga para evitar “task storms”
- Aislamiento por proceso (cada script es independiente)
- Pipeline de datos distribuido por jobs
- Logging sincronizado seguro en C++

---

## Cambios importantes respecto a la versión original

- [#] Backend Java eliminado
- [#] Modelo de ejecución basado en múltiples procesos estáticos
- [#] Sin control de colas ni scheduling

- [X] Nuevo backend en C++ (scheduler real)
- [X] ThreadPool interno
- [X] Dispatcher event-driven
- [X] Retry system con delayed queue
- [X] Control de sobrecarga (rate limiting)
- [X] Arquitectura tipo Celery simplificada

---

## Casos de uso

- Procesamiento paralelo de datasets
- Entrenamiento de modelos por script Lua
- Sistemas de simulación concurrente
- Pipelines de datos distribuidos
- Laboratorio de runtimes y schedulers

---

## Sistemas compatibles

- Debian:
  - 13 (Trixie)
  - 12 (Bookworm)

- Ubuntu:
  - 22.04 (Jammy)
  - 23.04 (Lunar Lobster)
  - 24.04 (Noble)

- Arch / CachyOS (probado en modo desarrollo; no recomendado para nivel producción)

---

## Instalación

```bash
git clone --recursive https://github.com/CarlosConLetraC/Actividad4_CienciaDeDatos.git
cd Actividad4_CienciaDeDatos
chmod +x initconsole cmd runclient *.sh
```

## Configurar entorno
```bash
./configurarentorno.sh
```

## Compilar
```bash
./build.sh
```

## Ejecución
```bash
./run.sh
```

---