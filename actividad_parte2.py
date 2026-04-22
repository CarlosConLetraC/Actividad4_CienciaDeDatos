import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import json
import numpy as np
import os

# CONFIG. . .
OUT_DIR = "plots"
os.makedirs(OUT_DIR, exist_ok=True)
sns.set(style="whitegrid", palette="deep")

# 1. CARGAR DATASET.
df = pd.read_csv("data/titanic_clean.csv")

# LABELS LEGIBLES. . .
df["sex_label"] = df["sex"].map({0: "Hombre", 1: "Mujer"})
df["survived_label"] = df["survived"].map({
	0: "No sobrevivio",
	1: "Sobrevivio"
})
df["alone_label"] = df["is_alone"].map({0: "Acompañado", 1: "Solo"})

# 2. CARGAR MODELO.
with open("data/coeficientes.json", "r") as f: model = json.load(f)
weights = np.array(model["weights"])
features = model["features"]
bias = model["bias"]
odds_ratios = np.exp(weights)


# FUNCION SAVE. . .
def saveplot(name):
	plt.tight_layout()
	plt.savefig(f"{OUT_DIR}/{name}", dpi=220)
	plt.close()


# 3. SUPERVIVENCIA POR SEXO.
plt.figure(figsize=(8, 5))
sns.barplot(x="sex_label", y="survived", data=df)
plt.title("Supervivencia por sexo")
plt.xlabel("Sexo")
plt.ylabel("Probabilidad de supervivencia")
saveplot("titanic_supervivencia_sexo.png")

# 4. SUPERVIVENCIA POR CLASE.
plt.figure(figsize=(8, 5))
sns.barplot(x="pclass", y="survived", data=df)
plt.title("Supervivencia por clase")
plt.xlabel("Clase")
plt.ylabel("Probabilidad de supervivencia")
saveplot("titanic_supervivencia_clase.png")

# 5. EDAD VS SUPERVIVENCIA (GENERAL).
plt.figure(figsize=(10, 6))
sns.histplot(data=df,
	x="age",
	hue="survived_label",
	bins=30,
	kde=True,
	alpha=0.55,
	multiple="layer")
plt.title("Distribucion de edad vs supervivencia")
plt.xlabel("Edad")
plt.ylabel("Frecuencia")
saveplot("titanic_edad_hist_general.png")

# 6. EDAD VS SUPERVIVENCIA HOMBRES.
plt.figure(figsize=(10, 6))
sns.histplot(data=df[df["sex"] == 0],
	x="age",
	hue="survived_label",
	bins=30,
	kde=True,
	alpha=0.55)
plt.title("Edad vs supervivencia (Hombres)")
plt.xlabel("Edad")
plt.ylabel("Frecuencia")
saveplot("titanic_edad_hombres.png")

# 7. EDAD VS SUPERVIVENCIA MUJERES.
plt.figure(figsize=(10, 6))
sns.histplot(data=df[df["sex"] == 1],
	x="age",
	hue="survived_label",
	bins=30,
	kde=True,
	alpha=0.55)
plt.title("Edad vs supervivencia (Mujeres)")
plt.xlabel("Edad")
plt.ylabel("Frecuencia")
saveplot("titanic_edad_mujeres.png")

# 8. BOXPLOT EDAD.
plt.figure(figsize=(8, 5))
sns.boxplot(x="survived_label", y="age", data=df)
plt.title("Edad vs supervivencia")
plt.xlabel("")
plt.ylabel("Edad")
saveplot("titanic_edad_boxplot.png")

# 9. FARE VS SUPERVIVENCIA.
plt.figure(figsize=(8, 5))
sns.boxplot(x="survived_label", y="fare", data=df)
plt.title("Tarifa pagada vs supervivencia")
plt.xlabel("")
plt.ylabel("Fare")
saveplot("titanic_fare_boxplot.png")

# 10. FAMILY SIZE.
plt.figure(figsize=(10, 5))
sns.barplot(x="family_size", y="survived", data=df)
plt.title("Supervivencia segun tamaño familiar")
plt.xlabel("Tamaño familiar")
plt.ylabel("Probabilidad de supervivencia")
saveplot("titanic_family_size.png")

# 11. SOLO VS ACOMPAÑADO.
plt.figure(figsize=(8, 5))
sns.barplot(x="alone_label", y="survived", data=df)
plt.title("Supervivencia: solo vs acompañado")
plt.xlabel("")
plt.ylabel("Probabilidad de supervivencia")
saveplot("titanic_is_alone.png")

# 12. MATRIZ CORRELACION.
plt.figure(figsize=(10, 8))
corr = df[[
	"sex", "pclass", "age", "fare", "sibsp", "parch", "family_size",
	"is_alone", "survived"
]].corr()
sns.heatmap(corr, annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Matriz de correlacion")
saveplot("titanic_correlacion.png")

# 13. COEFICIENTES.
plt.figure(figsize=(10, 5))
sns.barplot(x=features, y=weights)
plt.title("Coeficientes del modelo logistico")
plt.xlabel("Variables")
plt.ylabel("Peso")
plt.xticks(rotation=35)
saveplot("titanic_coeficientes.png")

# 14. ODDS RATIOS.
plt.figure(figsize=(10, 5))
sns.barplot(x=features, y=odds_ratios)
plt.title("Odds Ratios")
plt.xlabel("Variables")
plt.ylabel("Exp(coeficiente)")
plt.xticks(rotation=35)
saveplot("titanic_odds_ratios.png")

# 15. RESUMEN CONSOLA.
print("\n=========== MODELO TITANIC ===========")
print("Variables del modelo:\n")
for f, w, o in zip(features, weights, odds_ratios): print(f"{f:<12} coef={w:8.4f}   odds_ratio={o:8.4f}")
print("\nBias:", round(bias, 5))

print("\n=========== HALLAZGOS ===========")
print("Tasa supervivencia hombres:", round(df[df.sex == 0]["survived"].mean(), 3))
print("Tasa supervivencia mujeres:", round(df[df.sex == 1]["survived"].mean(), 3))
print("Supervivencia solos:", round(df[df.is_alone == 1]["survived"].mean(), 3))
print("Supervivencia acompañados:", round(df[df.is_alone == 0]["survived"].mean(), 3))
print("Edad promedio sobrevivientes:", round(df[df.survived == 1]["age"].mean(), 2))
print("Edad promedio no sobrevivientes:", round(df[df.survived == 0]["age"].mean(), 2))

print(f"\nGraficas guardadas en carpeta: {OUT_DIR}")
