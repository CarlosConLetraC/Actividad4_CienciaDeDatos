import("system", "csvfast", "Table", "json", "cml", "cstats")

local csv   = csvfast
local stats = cstats

-- LOAD RAW DATA
local file_name = system.curldownload("https://www.openml.org/data/get_csv/16826755/phpMYEkMl", true)
local data = csv.read_columns(file_name)
blund(data, "no se pudo cargar dataset")

-- BUILD DATASET (EN MEMORIA)
local dataset = {}
local rows = #data.survived

for i = 1, rows, 1 do
    local sex   = data.sex[i]
    local age   = tonumber(data.age[i]) or math.huge/math.huge
    local fare  = data.fare[i]
    local pcls  = data.pclass[i]
    local sibsp = data.sibsp[i]
    local parch = data.parch[i]
    local surv  = data.survived[i]

    -- filtro minimo NaN-safe
    if age == age and fare == fare and pcls == pcls and surv == surv then
        local family_size = sibsp + parch + 1
        local is_alone = (family_size == 1) and 1 or 0
        --[[dataset[#dataset + 1] =]]
        table.insert(dataset, {
            sex = (sex == "female") and 1 or 0,
            pclass = pcls,
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

print("Dataset limpio:", #dataset)
blund(#dataset > 20, "dataset insuficiente")

Table.shuffle(dataset)

-- MODEL TRAINING
local features = {
    "sex",
    "pclass",
    "age",
    "fare",
    "sibsp",
    "parch",
    "family_size",
    "is_alone"
}

local model = cml.LogisticRegression({
    features = features,
    target = "survived"
})

local result = model:fit(dataset, 0.05, 3000, 0.8)

-- METRICS
print("===== RESULTADOS =====")
print("Train Accuracy :", result.train.accuracy)
print("Test Accuracy  :", result.test.accuracy)
print("Train Loss     :", result.train.loss)
print("Test Loss      :", result.test.loss)

-- CORRELATIONS
local fare_list, age_list, surv_list = {}, {}, {}

for i = 1, #dataset, 1 do
    local r = dataset[i]
    fare_list[i] = r.fare
    age_list[i]  = r.age
    surv_list[i] = r.survived
end

print("Corr(fare,survived):", stats.corr(fare_list, surv_list))
print("Corr(age,survived) :", stats.corr(age_list, surv_list))

-- MODEL EXPORT (ONLY THING PERSISTED)
local export = model:export()

-- FIX: separar bias si viene incluido en weights
if #export.weights == #features + 1 then
    export.bias = table.remove(export.weights, 1)
end
--[[if #export.weights == #features + 1 then
    export.bias = export.weights[1]
    
    local new_weights = {}
    for i = 2, #export.weights do
        new_weights[#new_weights + 1] = export.weights[i]
    end
    export.weights = new_weights
end]]

local f = assert(io.open("data/coeficientes.json", "w"))
f:write(json.encode(export))
f:close()

-- EXAMPLE
local sample = dataset[#dataset]

print("===== EJEMPLO =====")
print("Valor real   :", sample.survived)
print("Prediccion   :", model:predict(sample))
print("Probabilidad :", model:probability(sample))