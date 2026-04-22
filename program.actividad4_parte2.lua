import("system", "csv", "Math", "Table", "json")

-- DESCARGA BASE DE DATOS.
local descarga = system.curldownload("https://www.openml.org/data/get_csv/16826755/phpMYEkMl", true)
local base_de_datos = csv.read(descarga)
local dataset = {}

-- LIMPIEZA.
local INVALID = {
	[""] = true,
	[" "] = true,
	["?"] = true,
	["NA"] = true,
	["N/A"] = true,
	["NULL"] = true
}

--[[local function is_valid(v)
	if v == nil then return false end
	v = csv.trim(tostring(v))
	return not INVALID[v]
end]]
local function is_valid(v) return v ~= nil and not INVALID[csv.trim(string.upper(tostring(v)))] end

-- PREPARACION + FEATURE ENGINEERING.
for i = 1, #base_de_datos, 1 do
	local row = base_de_datos[i]

	if is_valid(row.age) and
	   is_valid(row.fare) and
	   is_valid(row.sex) and
	   is_valid(row.pclass) and
	   is_valid(row.survived) and
	   is_valid(row.sibsp) and
	   is_valid(row.parch)
	then
		local age = tonumber(row.age)
		local fare = tonumber(row.fare)
		local pclass = tonumber(row.pclass)
		local survived = tonumber(row.survived)
		local sibsp = tonumber(row.sibsp)
		local parch = tonumber(row.parch)

		if age and fare and pclass and survived and sibsp and parch then
			local family_size = sibsp + parch + 1
			local is_alone = (family_size == 1) and 1 or 0

			table.insert(dataset, {
				sex = (row.sex == "female") and 1 or 0,
				pclass = pclass,
				age = age,
				fare = fare,
				sibsp = sibsp,
				parch = parch,
				family_size = family_size,
				is_alone = is_alone,
				survived = survived
			})
		end
	end
end

-- MEZCLAR DATASET.
Table.shuffle(dataset)

-- SPLIT TRAIN / TEST.
local split = math.floor(#dataset * 0.8)
local train, test = {}, {}

for i = 1, #dataset, 1 do
	table.insert((i <= split and train) or test, dataset[i])
	--if i <= split then
	--	table.insert(train, dataset[i])
	--else
	--	table.insert(test, dataset[i])
	--end
end

-- MODELO.
local modelo = Math.regresion_logistica(train, {
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

-- NORMALIZACION.
modelo:normalizar()

-- ENTRENAMIENTO.
modelo:entrenar(0.05, 3000)

-- EVALUACION.
print("Train size   :", #train)
print("Test size    :", #test)
print("Accuracy     :", modelo:accuracy(test))

-- EXPORTAR COEFICIENTES.
local f_json = io.open("data/coeficientes.json", "w")

local output = {
	features = modelo.features,
	weights = modelo.w,
	bias = modelo.bias
}

f_json:write(json.encode(output))
f_json:close()

-- EXPORTAR DATASET LIMPIO PARA PYTHON.
local f_csv = io.open("data/titanic_clean.csv", "w")
f_csv:write("sex,pclass,age,fare,sibsp,parch,family_size,is_alone,survived\n")
for i = 1, #dataset, 1 do
	local r = dataset[i]
	f_csv:write(string.format(
		"%d,%d,%f,%f,%d,%d,%d,%d,%d\n",
		r.sex,
		r.pclass,
		r.age,
		r.fare,
		r.sibsp,
		r.parch,
		r.family_size,
		r.is_alone,
		r.survived
	))
end
f_csv:close()

-- EJEMPLO DE PREDICCION.
local sample = test[1]
print("Ejemplo real :", sample.survived)
print("Prediccion   :", modelo:predecir(sample))
print("Probabilidad :", modelo:probabilidad(sample))