import os
import glob
import json
import math
import pandas as pd
import matplotlib.pyplot as plt

# =====================================================
# CONFIG
# =====================================================
JSON_PATTERN = "data/output_worker_*.json"
OUT_DIR = "plots"

os.makedirs(OUT_DIR, exist_ok=True)

# =====================================================
# LOAD FILES
# =====================================================
files = sorted(glob.glob(JSON_PATTERN))

if not files:
    print("No se encontraron JSON.")
    exit()

rows = []

# =====================================================
# HELPERS
# =====================================================
def num(v):
    """Convierte a float o NaN"""
    try:
        if v is None:
            return math.nan
        return float(v)
    except:
        return math.nan

# =====================================================
# READ JSON
# =====================================================
for file in files:
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)

    metrics = data.get("metrics", {})
    correlations = data.get("correlations", {})
    preds = data.get("predictions", [])

    row = {
        "worker_id": data.get("worker_id", 0),

        "rows_total": num(data.get("rows_total")),
        "train_size": num(data.get("train_size")),
        "test_size": num(data.get("test_size")),

        "r2_train": num(metrics.get("r2_train")),
        "mse_train": num(metrics.get("mse_train")),
        "rmse_train": num(metrics.get("rmse_train")),

        "r2_test": num(metrics.get("r2_test")),
        "mse_test": num(metrics.get("mse_test")),
        "rmse_test": num(metrics.get("rmse_test")),

        "corr_odometer": num(correlations.get("odometer_price")),
        "corr_mmr": num(correlations.get("mmr_price")),

        "pred_count": len(preds)
    }

    rows.append(row)

# =====================================================
# DATAFRAME
# =====================================================
df = pd.DataFrame(rows)

if df.empty:
    print("No hay datos.")
    exit()

df = df.sort_values("worker_id")
df.replace([math.inf, -math.inf], math.nan, inplace=True)

# guardar csv
df.to_csv(f"{OUT_DIR}/resumen_workers.csv", index=False)

# =====================================================
# GRAFICA 1 R2 TEST
# =====================================================
tmp = df.dropna(subset=["r2_test"])

if not tmp.empty:
    plt.figure(figsize=(12,6))
    plt.bar(tmp["worker_id"], tmp["r2_test"])
    plt.title("R² Test por Worker")
    plt.xlabel("Worker")
    plt.ylabel("R²")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/parte1_r2_test.png", dpi=200)
    plt.close()

# =====================================================
# GRAFICA 2 RMSE TEST
# =====================================================
tmp = df.dropna(subset=["rmse_test"])

if not tmp.empty:
    plt.figure(figsize=(12,6))
    plt.bar(tmp["worker_id"], tmp["rmse_test"])
    plt.title("RMSE Test por Worker")
    plt.xlabel("Worker")
    plt.ylabel("RMSE")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/parte1_rmse_test.png", dpi=200)
    plt.close()

# =====================================================
# GRAFICA 3 ROWS
# =====================================================
tmp = df.dropna(subset=["rows_total"])

if not tmp.empty:
    plt.figure(figsize=(12,6))
    plt.bar(tmp["worker_id"], tmp["rows_total"])
    plt.title("Cantidad de registros por Worker")
    plt.xlabel("Worker")
    plt.ylabel("Rows")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/parte1_rows_worker.png", dpi=200)
    plt.close()

# =====================================================
# GRAFICA 4 CORRELACIONES
# =====================================================
tmp = df.dropna(subset=["corr_odometer", "corr_mmr"], how="all")

if not tmp.empty:
    plt.figure(figsize=(12,6))

    if tmp["corr_odometer"].notna().any():
        plt.plot(
            tmp["worker_id"],
            tmp["corr_odometer"],
            marker="o",
            label="Odometer vs Price"
        )

    if tmp["corr_mmr"].notna().any():
        plt.plot(
            tmp["worker_id"],
            tmp["corr_mmr"],
            marker="o",
            label="MMR vs Price"
        )

    plt.title("Correlaciones")
    plt.xlabel("Worker")
    plt.ylabel("Correlación")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/parte1_correlaciones.png", dpi=200)
    plt.close()

# =====================================================
# GRAFICA 5 BOXPLOT R2
# =====================================================
vals = df["r2_test"].dropna()

if len(vals) > 0:
    plt.figure(figsize=(8,6))
    plt.boxplot(vals, tick_labels=["R² Test"])
    plt.title("Distribución R² Test")
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/parte1_boxplot_r2.png", dpi=200)
    plt.close()

# =====================================================
# GRAFICA 6 REAL VS PRED
# =====================================================
reales = []
preds = []

for file in files:
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)

    for item in data.get("predictions", []):
        real = num(item.get("real"))
        pred = num(item.get("pred"))

        if not math.isnan(real) and not math.isnan(pred):
            reales.append(real)
            preds.append(pred)

if reales:
    plt.figure(figsize=(8,8))

    plt.scatter(reales, preds, alpha=0.55, s=35)

    mn = min(min(reales), min(preds))
    mx = max(max(reales), max(preds))

    plt.plot([mn, mx], [mn, mx], "--", linewidth=2)

    plt.title("Real vs Predicho")
    plt.xlabel("Real")
    plt.ylabel("Predicho")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/parte1_real_vs_pred.png", dpi=250)
    plt.close()

# =====================================================
# RESUMEN
# =====================================================
print("\n===== RESUMEN GENERAL =====")
print(df.describe())

if df["r2_test"].notna().any():
    best = df.loc[df["r2_test"].idxmax()]
    print("\nMejor Worker:")
    print(best[["worker_id", "r2_test", "rmse_test"]])

if df["rmse_test"].notna().any():
    worst = df.loc[df["rmse_test"].idxmax()]
    print("\nPeor Worker:")
    print(worst[["worker_id", "r2_test", "rmse_test"]])

print(f"\nGraficas guardadas en: {OUT_DIR}")