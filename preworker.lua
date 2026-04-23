import("Table", "csvfast", "json", "system", "cml", "cstats")
local csv = csvfast

local string_format = string.format
local math_floor = math.floor
local math_abs = math.abs
local table_insert = table.insert

-- START
local function start(workerId, totalWorkers, inputCSV, outputPrefix)
	workerId = tonumber(workerId)
	totalWorkers = tonumber(totalWorkers)

	-- LOAD CSV
	local columns = csv.read_columns(inputCSV)
	local priceCol = columns.sellingprice
	local odoCol   = columns.odometer
	local mmrCol   = columns.mmr

	assert(priceCol and odoCol and mmrCol, "faltan columnas")
	local totalRows = #priceCol

	-- SHARDING
	local base = math_floor(totalRows / totalWorkers)
	local extra = totalRows % totalWorkers
	local start_row, limit

	if workerId <= extra then
		limit = base + 1
		start_row = (workerId - 1) * limit + 1
	else
		limit = base
		start_row = extra * (base + 1) + (workerId - extra - 1) * base + 1
	end

	local end_row = start_row + limit - 1

	-- OUTPUT CSV
	local outputCSV = string_format("%s%d.csv", outputPrefix, workerId)
	local out = assert(io.open(outputCSV, "w"))
	out:write("sellingprice,odometer,mmr\n")

	-- DATASET
	local dataset    = {}
	local price_list = {}
	local odo_list   = {}
	local mmr_list   = {}

	csv.each(inputCSV, function(row, emitted, i)
		local price = row.sellingprice
		local odom  = row.odometer
		local mmr   = row.mmr

		if price and odom and mmr then
			out:write(string_format("%f,%f,%f\n", price, odom, mmr))

			table_insert(dataset, {
				Odometer = odom,
				MMR = mmr,
				Price = price
			})

			table_insert(price_list, price)
			table_insert(odo_list, odom)
			table_insert(mmr_list, mmr)
		end
	end, {
		start_row = start_row,
		limit = limit
	})

	out:close()

	system.print(string_format(
		"[Worker %d] rows=%d validas=%d",
		workerId,
		limit,
		#dataset
	))

	if #dataset < 10 then
		system.print("[Worker " .. workerId .. "] dataset demasiado pequeño")
		return
	end

	-- RANDOMIZE
	Table.shuffle(dataset)

	-- CORRELATIONS (C MODULE)
	local corr_odometer = cstats.corr(odo_list, price_list)
	local corr_mmr      = cstats.corr(mmr_list, price_list)

	-- MODEL
	local model = cml.LinearRegression({
		features = {"Odometer", "MMR"},
		target = "Price"
	})

	local result = model:fit(dataset, 0.01, 1000, 0.8)

	-- DEBUG
	system.print("===== WORKER " .. workerId .. " =====")
	system.print("R2 Train:", result.train.r2)
	system.print("R2 Test:", result.test.r2)
	system.print("MSE Train:", result.train.mse)
	system.print("MSE Test:", result.test.mse)
	system.print("RMSE Train:", result.train.rmse)
	system.print("RMSE Test:", result.test.rmse)

	-- PREDICTIONS
	local predictions = {}
	local y_real = {}
	local y_pred = {}

	for i = 1, #dataset, 1 do
		local pred = model:predict(dataset[i])
		local real = dataset[i].Price

		table_insert(y_real, real)
		table_insert(y_pred, pred)
		table_insert(predictions, {
			real = real,
			pred = pred,
			error = pred - real,
			abs_error = math_abs(pred - real),
			odometer = dataset[i].Odometer,
			mmr = dataset[i].MMR
		})
	end

	-- EXTRA GLOBAL METRICS (C MODULE)
	local full_r2   = cstats.r2(y_real, y_pred)
	local full_mse  = cstats.mse(y_real, y_pred)
	local full_rmse = full_mse ^ 0.5

	-- SAVE JSON
	local train_size = math_floor(#dataset * 0.8)
	local test_size  = #dataset - train_size

	local salida = {
		worker_id = workerId,

		rows_total = #dataset,
		train_size = train_size,
		test_size = test_size,

		metrics = {
			r2_train = result.train.r2,
			mse_train = result.train.mse,
			rmse_train = result.train.rmse,

			r2_test = result.test.r2,
			mse_test = result.test.mse,
			rmse_test = result.test.rmse,

			r2_full = full_r2,
			mse_full = full_mse,
			rmse_full = full_rmse
		},

		correlations = {
			odometer_price = corr_odometer,
			mmr_price = corr_mmr
		},

		predictions = predictions
	}

	local jsonPath = string_format("data/output_worker_%d.json", workerId)
	local f = assert(io.open(jsonPath, "w"))
	f:write(json.encode(salida))
	f:close()
	system.print("[Worker " .. workerId .. "] JSON guardado")
end

return {start = start}