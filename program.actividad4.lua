import("csv", "system")
local workerName = ...
local workerId = tonumber(string.match(workerName, "(%d+)"))
system.print(workerName, workerId)
do return end

local out = io.open("data/dataset_regresion.csv", "w")
out:write("odometer,mmr,sellingprice\n")

local count = 0

local function clean_number(x)
    x = tonumber(x)
    if not x then return nil end
    if x ~= x then return nil end -- NaN check
    return x
end

local function process(row)
    local odometer = clean_number(row.odometer)
    local mmr = clean_number(row.mmr)
    local price = clean_number(row.sellingprice)

    -- validacion fuerte (clave para regresión estable)
    if odometer and mmr and price then
        if odometer > 0 and odometer < 300000 and
           mmr > 500 and mmr < 200000 and
           price > 500 and price < 200000 then

            out:write(
                odometer .. "," ..
                mmr .. "," ..
                price .. "\n"
            )

            count = count + 1
        end
    end
end

csv.each("data/car_prices.csv", process, {
    start_row = 1,
    limit = 10
})
out:close()

print("Dataset listo para regresión: " .. count .. " filas")