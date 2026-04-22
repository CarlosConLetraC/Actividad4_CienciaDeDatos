local CodigoFuenteWorker = [[import("preworker", "Math", "File", "Table", "csvfast")
local BASE_DE_DATOS = "data/car_prices.csv"
local PREFIX_SALIDA_REGRESION = "data/dataset_regresion"

preworker.start(INT_WORKER_ID, INT_TOTAL_WORKERS, BASE_DE_DATOS, PREFIX_SALIDA_REGRESION)]]

local INT_TOTAL_WORKERS = 10
local PATH_OUTPUT = "daemons"
os.execute("mkdir -p "..PATH_OUTPUT)
os.execute("rm -rf "..PATH_OUTPUT.."/*")
os.execute("rm -rf data/dataset_regresion*")
os.execute("rm -rf data/output_worker_*")
os.execute("rm -rf plots/parte1_*")

src = string.gsub(CodigoFuenteWorker, "INT_TOTAL_WORKERS", tostring(INT_TOTAL_WORKERS))
for i = 1, INT_TOTAL_WORKERS, 1 do
	local f = assert(io.open(PATH_OUTPUT.."/program.worker"..i..".lua", "w"))
	local newSrc = string.gsub(src, "INT_WORKER_ID", i)
	f:write(newSrc)
	f:close()
end

