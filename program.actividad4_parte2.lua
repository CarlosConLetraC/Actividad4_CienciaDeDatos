import("system", "csvfast", "Table", "json", "cml", "cstats")

local csv   = csvfast
local stats = cstats

-- DATASET
local file_name = system.curldownload("https://www.openml.org/data/get_csv/16826755/phpMYEkMl", true)
local data = csv.read_columns(file_name)
assert(data, "no se pudo cargar dataset")
local dataset = {}
local rows = #data.survived

for i = 1, rows, 1 do
    local sex = data.sex[i]
    local age = tonumber(data.age[i]) or math.huge/math.huge
    local fare = data.fare[i]
    local pclass = data.pclass[i]
    local sibsp = data.sibsp[i]
    local parch = data.parch[i]
    local surv = data.survived[i]

    -- filtro minimo (evitar NaN)
    if age == age and fare == fare and pclass == pclass and surv == surv then
        local family_size = sibsp + parch + 1
        local is_alone = (family_size == 1) and 1 or 0

        table.insert(dataset, {
            sex = (sex == "female") and 1 or 0,
            pclass = pclass,
            age = age,
            fare = fare,
            sibsp = sibsp,
            parch = parch,
            family_size = family_size,
            is_alone = is_alone,
            survived = (surv == 1 or surv == "1" or surv == true) and 1 or 0
        })
    end
end

print("Dataset limpio :", #dataset)
assert(#dataset > 20, "dataset insuficiente")
Table.shuffle(dataset)

-- MODELO
local model = cml.LogisticRegression({
    features = {
        "sex",
        "pclass",
        "age",
        "fare",
        "sibsp",
        "parch",
        "family_size",
        "is_alone"
    },
    target = "survived"
})

local result = model:fit(dataset, 0.05, 3000, 0.8)

-- METRICAS
print("===== RESULTADOS =====")
print("Train Accuracy :", result.train.accuracy)
print("Test Accuracy  :", result.test.accuracy)
print("Train Loss     :", result.train.loss)
print("Test Loss      :", result.test.loss)

-- CORRELACIONES
local fare_list, age_list, surv_list = {}, {}, {}

for i = 1, #dataset do
    local r = dataset[i]
    fare_list[i] = r.fare
    age_list[i]  = r.age
    surv_list[i] = r.survived
end

print("Corr(fare,survived):", stats.corr(fare_list, surv_list))
print("Corr(age,survived) :", stats.corr(age_list, surv_list))

-- EXPORT MODELO (IMPORTANTE)
local export = model:export()

local f = assert(io.open("data/coeficientes.json", "w"))
f:write(json.encode(export))
f:close()

-- EJEMPLO
local sample = dataset[#dataset]

print("===== EJEMPLO =====")
print("Valor real   :", sample.survived)
print("Predicción   :", model:predict(sample))
print("Probabilidad :", model:probability(sample))