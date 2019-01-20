--[[
	Does not handle recursive tables
]]
function cloneTable(tbl, depth)
	if (type(depth) ~= 'number') then
		depth = 1
	end

	if (depth <= 0) then
		return tbl
	end

	local new = {}

	for i, v in pairs(tbl) do
		if (type(v) == 'table') then
			new[i] = cloneTable(v, depth - 1)
		else
			new[i] = v
		end
	end

	return new
end

function tableToString(tbl, ind, printed)
	if (ind == nil) then
		ind = ''
	end

	if (printed == nil) then
		printed = {}
	end

	if (tbl == nil) then
		error('tbl is nil', 2)
	end

	-- hardTable functions aren't defined yet
	-- if (isHardTable(tbl)) then
	-- 	tbl = hardTableExport(tbl)
	-- end

	if (printed[tbl]) then
		return tostring(tbl)
	end

	printed[tbl] = true

	local r = tostring(tbl) .. ' {\n'

	for i, v in pairs(tbl) do
		r = r .. ind .. '[' .. tostring(i) .. ']: '

		if (type(v) == 'table') then
			r = r .. tableToString(v, ind .. ' ', printed) .. ',\n'
		else
			r = r .. tostring(v) .. ',\n'
		end
	end

	r = r .. ind .. '}'

	return r
end

--[[
	Counts the number of properties in a table
]]
function countKeys(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end
