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

--[[
	Returns a list of all keys in a table.
]]
function tableKeys(tbl)
	local result = {}
	for key in pairs(tbl) do
		table.insert(result, key)
	end
	return result
end

--[[
	Sorts the keys in a table
]]
function sortTableKeys(keys)
	local numericKeys = {}
	local stringKeys = {}
	local unsortableKeys = {}

	for _, key in ipairs(keys) do
		if (type(key) == 'number') then
			table.insert(numericKeys, key)
		elseif (type(key) == 'string') then
			table.insert(stringKeys, key)
		else
			table.insert(unsortableKeys, key)
		end
	end

	table.sort(stringKeys)
	table.sort(numericKeys)

	local result = {}

	for _, key in ipairs(numericKeys) do
		table.insert(result, key)
	end

	for _, key in ipairs(stringKeys) do
		table.insert(result, key)
	end

	for _, key in ipairs(unsortableKeys) do
		table.insert(result, key)
	end

	return result
end

function sortedTableKeys(tbl)
	return sortTableKeys(tableKeys(tbl))
end

--[[
	Serializes things, doesn't handle class types. Try if you have one, obj:serialize()
]]
function serialize(obj, indent, parents)
	local typ = type(obj)

	if (typ == 'nil') then
		return 'nil'
	end

	if (typ == 'number') then
		return tostring(obj)
	end

	if (typ == 'string') then
		return "'" .. (obj:gsub("(['\\])", '\\%1')) .. "'"
	end

	if (typ == 'function') then
		error("Can't serialize functions", 2)
	end

	if (typ == 'table') then
		indent = coalesce(indent, '')
		parents = coalesce(parents, {})

		if (parents[obj] == true) then
			error("Can't serialize recursive table", 2)
		end

		parents[obj] = true

		local isClass = isType(obj, Class)
		local data = obj

		if (isClass and type(obj.serialize) == 'function') then
			data = obj:serialize()
		elseif (isHardTable(obj)) then
			data = hardTableExport(obj)
		end

		local resultParts = {}
		local newLine = '\n' .. indent

		--TODO: maybe, someday
		-- if (isClass) then
		-- 	table.insert(resultParts, '<')
		-- 	table.insert(resultParts, obj.ClassName)
		-- else
		table.insert(resultParts, '{')
		-- end

		local keys = sortedTableKeys(data)

		if (#keys > 0) then
			table.insert(resultParts, newLine)

			for _, key in pairs(keys) do
				local keyType = type(key)

				table.insert(resultParts, '\t')

				if (keyType == 'string') then
					local needsBraces = not stringutil.matchesPattern(key, '^[%a_][%w_]*$')

					if (needsBraces) then
						table.insert(resultParts, '[')
						table.insert(resultParts, serialize(key))
						table.insert(resultParts, ']')
					else
						table.insert(resultParts, key)
					end
				elseif (keyType == 'number') then
					table.insert(resultParts, '[')
					table.insert(resultParts, key)
					table.insert(resultParts, ']')
				elseif (keyType == 'table') then
					table.insert(resultParts, '[')
					table.insert(resultParts, serialize(key, indent .. '\t', parents))
					table.insert(resultParts, ']')
				else
					error("Can't serialize key of type " .. keyType, 2)
				end
				table.insert(resultParts, ' = ')

				table.insert(resultParts, serialize(data[key], indent .. '\t', parents))
				table.insert(resultParts, ',')
				table.insert(resultParts, newLine)
			end
		end

		-- if (isClass) then
		-- 	table.insert(resultParts, '>')
		-- else
		table.insert(resultParts, '}')
		-- end

		parents[obj] = nil

		return table.concat(resultParts, '')
	end

	error('Unknown type to serialize', 2)
end

function deserialize(str)
	return textutils.unserialize(str)
end
