import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import json
import numpy as np
import os

# =====================================================
# CONFIGURACION
# =====================================================
OUT_DIR = "plots"
os.makedirs(OUT_DIR, exist_ok=True)

sns.set(style="whitegrid", palette="deep")

# =====================================================
# 1. CARGAR DATASET (YA LIMPIO POR C++/LUAJIT)
# =====================================================
df = pd.read_csv("data/titanic_clean.csv")

# LABELS LEGIBLES
df["sex_label"] = df["sex"].map({0: "Hombre", 1: "Mujer"})
df["survived_label"] = df["survived"].map({
    0: "No sobrevivió",
    1: "Sobrevivió"
})
df["alone_label"] = df["is_alone"].map({
    0: "Acompañado",
    1: "Solo"
})

# =====================================================
# 2. MODELO (cml LogisticRegression)
# =====================================================
with open("data/coeficientes.json", "r") as f:
    model = json.load(f)

weights = np.array(model["weights"])
features = model["features"]

# Bias puede o no existir según versión
bias = model.get("bias", 0.0)

odds_ratios = np.exp(weights)

# =====================================================
# UTILIDAD SAVE
# =====================================================
def saveplot(name):
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/{name}", dpi=220)
    plt.close()

# =====================================================
# 3. SUPERVIVENCIA POR SEXO
# =====================================================
plt.figure(figsize=(8, 5))
sns.barplot(x="sex_label", y="survived", data=df)
plt.title("Supervivencia por sexo")
plt.xlabel("Sexo")
plt.ylabel("Probabilidad de supervivencia")
saveplot("01_supervivencia_sexo.png")

# =====================================================
# 4. SUPERVIVENCIA POR CLASE
# =====================================================
plt.figure(figsize=(8, 5))
sns.barplot(x="pclass", y="survived", data=df)
plt.title("Supervivencia por clase")
plt.xlabel("Clase")
plt.ylabel("Probabilidad de supervivencia")
saveplot("02_supervivencia_clase.png")

# =====================================================
# 5. EDAD VS SUPERVIVENCIA
# =====================================================
plt.figure(figsize=(10, 6))
sns.histplot(
    data=df,
    x="age",
    hue="survived_label",
    bins=30,
    kde=True,
    alpha=0.55,
    multiple="layer"
)
plt.title("Distribución de edad vs supervivencia")
plt.xlabel("Edad")
plt.ylabel("Frecuencia")
saveplot("03_edad_general.png")

# =====================================================
# 6. HOMBRES
# =====================================================
plt.figure(figsize=(10, 6))
sns.histplot(
    data=df[df["sex"] == 0],
    x="age",
    hue="survived_label",
    bins=30,
    kde=True,
    alpha=0.55
)
plt.title("Edad vs supervivencia (Hombres)")
saveplot("04_edad_hombres.png")

# =====================================================
# 7. MUJERES
# =====================================================
plt.figure(figsize=(10, 6))
sns.histplot(
    data=df[df["sex"] == 1],
    x="age",
    hue="survived_label",
    bins=30,
    kde=True,
    alpha=0.55
)
plt.title("Edad vs supervivencia (Mujeres)")
saveplot("05_edad_mujeres.png")

# =====================================================
# 8. BOXPLOT EDAD
# =====================================================
plt.figure(figsize=(8, 5))
sns.boxplot(x="survived_label", y="age", data=df)
plt.title("Edad vs supervivencia")
saveplot("06_box_age.png")

# =====================================================
# 9. FARE VS SUPERVIVENCIA
# =====================================================
plt.figure(figsize=(8, 5))
sns.boxplot(x="survived_label", y="fare", data=df)
plt.title("Tarifa vs supervivencia")
saveplot("07_box_fare.png")

# =====================================================
# 10. TAMAÑO FAMILIAR
# =====================================================
plt.figure(figsize=(10, 5))
sns.barplot(x="family_size", y="survived", data=df)
plt.title("Supervivencia según tamaño familiar")
saveplot("08_family_size.png")

# =====================================================
# 11. SOLO VS ACOMPAÑADO
# =====================================================
plt.figure(figsize=(8, 5))
sns.barplot(x="alone_label", y="survived", data=df)
plt.title("Supervivencia: solo vs acompañado")
saveplot("09_alone.png")

# =====================================================
# 12. CORRELACION
# =====================================================
plt.figure(figsize=(10, 8))
corr = df[
    ["sex", "pclass", "age", "fare",
     "sibsp", "parch", "family_size",
     "is_alone", "survived"]
].corr()

sns.heatmap(corr, annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Matriz de correlación")
saveplot("10_corr.png")

# =====================================================
# 13. COEFICIENTES
# =====================================================
plt.figure(figsize=(10, 5))
sns.barplot(x=features, y=weights)
plt.title("Coeficientes del modelo logístico")
plt.xticks(rotation=35)
saveplot("11_coeficientes.png")

# =====================================================
# 14. ODDS RATIOS
# =====================================================
plt.figure(figsize=(10, 5))
sns.barplot(x=features, y=odds_ratios)
plt.title("Odds Ratios")
plt.xticks(rotation=35)
saveplot("12_odds.png")

# =====================================================
# 15. RESUMEN
# =====================================================
print("\n=========== MODELO TITANIC ===========")
for f, w, o in zip(features, weights, odds_ratios):
    print(f"{f:<15} coef={w:8.4f} odds={o:8.4f}")

print("\nBias:", round(bias, 6))

print("\n=========== HALLAZGOS ===========")
print("Supervivencia hombres:", round(df[df.sex == 0]["survived"].mean(), 3))
print("Supervivencia mujeres:", round(df[df.sex == 1]["survived"].mean(), 3))
print("Solo:", round(df[df.is_alone == 1]["survived"].mean(), 3))
print("Acompañado:", round(df[df.is_alone == 0]["survived"].mean(), 3))

print("\nGraficas guardadas en:", OUT_DIR)