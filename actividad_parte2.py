import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import os

# CONFIG
OUT_DIR = "plots"
os.makedirs(OUT_DIR, exist_ok=True)
sns.set(style="whitegrid")

# 1. LOAD MODEL ONLY
with open("data/coeficientes.json", "r") as f:
    model = json.load(f)

features = model["features"]
weights  = np.array(model["weights"], dtype=float)
bias     = model.get("bias", 0.0)

# 2. SIMULATED FEATURE SPACE
#    (reemplaza dataset real)
np.random.seed(42)
N = 1000

X = {}

for f in features:
    match f:
        case "sex" | "is_alone":
            X[f] = np.random.randint(0, 2, N)

        case "pclass":
            X[f] = np.random.randint(1, 4, N)

        case "age":
            X[f] = np.random.normal(30, 12, N).clip(0, 80)

        case "fare":
            X[f] = np.random.gamma(2, 20, N)

        case _:
            X[f] = np.random.normal(0, 1, N)

# 3. LOGISTIC MODEL SIMULATION
def sigmoid(z): return 1 / (1 + np.exp(-z))

Z = bias
for i, f in enumerate(features): Z += X[f] * weights[i]

proba = sigmoid(Z)
pred = (proba > 0.5).astype(int)

# 4. ANALYTICS DATAFRAME-LIKE
sex = X.get("sex", np.zeros(N))

# 5. VISUALIZATIONS

# Survival rate by sex
plt.figure(figsize=(6,4))
plt.bar(["Hombre", "Mujer"],
        [pred[sex==0].mean(), pred[sex==1].mean()])
plt.title("Supervivencia simulada por sexo")
plt.savefig(f"{OUT_DIR}/01_sex.png")
plt.close()

# Distribution of probabilities
plt.figure(figsize=(7,4))
plt.hist(proba, bins=30, alpha=0.7)
plt.title("Distribución de probabilidades del modelo")
plt.savefig(f"{OUT_DIR}/02_proba.png")
plt.close()

# Feature importance (weights)
plt.figure(figsize=(8,4))
sns.barplot(x=features, y=weights)
plt.xticks(rotation=35)
plt.title("Importancia de features (modelo)")
plt.savefig(f"{OUT_DIR}/03_weights.png")
plt.close()

# Odds ratios
plt.figure(figsize=(8,4))
sns.barplot(x=features, y=np.exp(weights))
plt.xticks(rotation=35)
plt.title("Odds ratios")
plt.savefig(f"{OUT_DIR}/04_odds.png")
plt.close()

# 6. SUMMARY
print("\n=========== MODELO (SIN CSV) ===========")
for f, w in zip(features, weights): print(f"{f:<15} weight={w:8.4f}")
print("\nBias:", bias)
print("\nAccuracy simulada:", (pred == (proba > 0.5)).mean())
print("Prob media:", proba.mean())