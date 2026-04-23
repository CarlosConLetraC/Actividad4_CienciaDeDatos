# Actividad 4 (Parte 2) --- Análisis de Sobrevivencia en el Titanic con Regresión Logística Binaria

## Resumen Ejecutivo

Se desarrolló un modelo de regresión logística binaria para predecir la
sobrevivencia de pasajeros del Titanic utilizando un pipeline eficiente
basado en LuaJIT + C/C++ para entrenamiento y Python para visualización.

------------------------------------------------------------------------

# Objetivos

## Objetivo General

Predecir la sobrevivencia de pasajeros usando variables demográficas y
socioeconómicas.

## Objetivos Específicos

-   Limpieza de datos
-   Transformación de variables
-   Análisis exploratorio
-   Entrenamiento de modelo
-   Interpretación de coeficientes

------------------------------------------------------------------------

# Dataset

Fuente: https://www.openml.org/data/get_csv/16826755/phpMYEkMl

## Variable Dependiente

-   survived

## Variables Independientes

-   sex
-   pclass
-   age
-   fare
-   sibsp
-   parch
-   family_size
-   is_alone

Dataset limpio final: **1045 registros**

------------------------------------------------------------------------

# Limpieza y Preparación

-   Eliminación de valores nulos
-   Codificación binaria de variables categóricas
-   Creación de:
    -   family_size
    -   is_alone

------------------------------------------------------------------------

# Análisis Exploratorio

## Correlaciones

-   fare vs survived: 0.2491 (positiva)
-   age vs survived: -0.0539 (ligera negativa)

------------------------------------------------------------------------

# División de Datos

-   80% entrenamiento
-   20% prueba

------------------------------------------------------------------------

# Modelo

Regresión Logística Binaria:

P(survived) = σ(β0 + Σ βiXi)

Parámetros: - Learning rate: 0.05 - Iteraciones: 3000

------------------------------------------------------------------------

# Resultados

## Métricas

  Métrica          Valor
  ---------------- --------
  Train Accuracy   0.8002
  Test Accuracy    0.7799
  Train Loss       0.1997
  Test Loss        0.2200

------------------------------------------------------------------------

# Coeficientes

  Variable      Peso
  ------------- ---------
  sex           1.2084
  pclass        -0.8700
  age           -0.5948
  fare          0.0764
  sibsp         -0.3726
  parch         -0.0048
  family_size   -0.2389
  is_alone      -0.3877

Bias: -0.4143

------------------------------------------------------------------------

# Odds Ratios

Interpretación usando exp(β):

-   sex → aumenta fuertemente probabilidad
-   pclass → reduce probabilidad
-   age → efecto negativo moderado

------------------------------------------------------------------------

# Interpretación

-   Ser mujer incrementa significativamente la sobrevivencia
-   Clases altas tienen mayor probabilidad
-   Mayor tarifa mejora supervivencia
-   Viajar solo reduce probabilidad

------------------------------------------------------------------------

# Ejemplo

-   Valor real: 1
-   Predicción: 0
-   Probabilidad: 0.1146

------------------------------------------------------------------------

# Visualización

Gráficas generadas: - Supervivencia por sexo - Distribución de
probabilidades - Importancia de variables - Odds ratios

Ubicación: /plots

------------------------------------------------------------------------

# Arquitectura

Pipeline:

LuaJIT + C/C++ → entrenamiento → JSON → Python → gráficas

------------------------------------------------------------------------

# Limitaciones

-   Sin validación cruzada
-   Sin regularización
-   t-test no implementado explícitamente

------------------------------------------------------------------------

# Mejoras Futuras

-   Ridge / Lasso
-   Random Forest
-   Gradient Boosting
-   Redes neuronales

------------------------------------------------------------------------

# Conclusión

El modelo logra una precisión cercana al 78% en test, identificando
correctamente variables clave como sexo, clase y tarifa.

Se demuestra la eficiencia de integrar LuaJIT con C/C++ para machine
learning y Python para análisis.