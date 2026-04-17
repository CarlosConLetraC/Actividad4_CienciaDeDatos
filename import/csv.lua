local table_insert = table.insert
local table_concat = table.concat

local string_sub = string.sub
local string_match = string.match
local string_gsub = string.gsub
local string_find = string.find
local string_format = string.format

local math_max = math.max

local tostring, assert, tonumber = tostring, assert, tonumber

local csv = {}
local function trim(s)
	local s = string_gsub(s, "^%s+", "")
	return (string_gsub(s, "%s+$", ""))
end
csv.trim = trim

local function escape_csv(v)
	v = tostring(v or "")

	if string_find(v, '[",]') then
		v = string_format("\"%s\"", string_gsub(v, '"', '""'))--'"' .. string_gsub(v, '"', '""') .. '"'
	end

	return v
end

local function split_csv(line)
	local res = {}
	local buf = ""
	local in_quotes = false

	for i = 1, #line, 1 do
		local c = string_sub(line, i, i)

		if c == '"' then
			-- handle escaped quotes ""
			if in_quotes and string_sub(line, i+1, i+1) == '"' then
				buf = buf .. '"'
				i = i + 1
			else
				in_quotes = not in_quotes
			end
		elseif c == ',' and not in_quotes then
			table_insert(res, buf)
			buf = ""
		else
			buf = buf .. c
		end
	end

	table_insert(res, buf)
	return res
end

function csv.read(path)
	local file = assert(io.open(path, "r"))
	local headers = split_csv(file:read("*l"))

	local rows = {}--Table_new()

	for line in file:lines() do
		line = string_gsub(line, "\r", "")
		if line ~= "" then
			local cols = split_csv(line)
			local row = {}--Table_new()

			local max_len = math_max(#headers, #cols)

			for i = 1, max_len, 1 do
				local h = headers[i]
				if h then
					h = string_gsub(h, "\13", "")
					local v = cols[i]

					if v ~= nil then
						v = trim(v)
						v = string_gsub(v, '^"(.*)"$', "%1")
						--v = string_gsub(v, "\r", "")
						row[h] = tonumber(v) or v
					else
						row[h] = nil
					end
				end
			end

			--rows[rawlen(rows) + 1] = row
			table_insert(rows, row)
		end
	end

	file:close()
	return rows
end

function csv.write(path, headers, rows)
	local file = assert(io.open(path, "w"))

	-- headers
	local h = {}
	for i = 1, #headers, 1 do
		h[i] = escape_csv(headers[i])
	end
	file:write(table_concat(h, ",") .. "\n")

	-- rows
	for _, row in ipairs(rows) do
		local line = {}

		for i = 1, #headers, 1 do
			local v = row[headers[i]]
			line[i] = escape_csv(v)
		end

		file:write(table_concat(line, ",") .. "\n")
	end

	file:close()
end

function csv.each(path, fn, opts)
	opts = opts or {}
	opts.start_row = opts.start_row or 1
	opts.offset    = opts.offset or 0
	opts.sample    = opts.sample or 1
	opts.limit     = opts.limit  or math.huge

	local file = assert(io.open(path, "r"))
	local headers = split_csv(file:read("*l"))

	local i = 0
	local emitted = 0

	for line in file:lines() do
		line = string_gsub(line, "\r", "")

		if line ~= "" then
			i = i + 1
			if i >= opts.start_row then
				local rel_i = i - opts.start_row + 1
				if rel_i > opts.offset and ((rel_i - opts.offset) % opts.sample == 0) then
					local cols = split_csv(line)
					local row = {}

					for j = 1, #headers, 1 do
						local h = headers[j]
						if h then
							h = string_gsub(h, "\r", "")
							local v = cols[j]

							if v ~= nil then
								v = trim(v)
								v = string_gsub(v, '^"(.*)"$', "%1")
								row[h] = tonumber(v) or v
							end
						end
					end

					emitted = emitted + 1
					fn(row, emitted, i)

					if emitted >= opts.limit then
						break
					end
				end
			end
		end
	end

	file:close()
end

return csv