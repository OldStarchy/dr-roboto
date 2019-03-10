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

	if (isType(tbl, Class)) then
		return deserialize(serialize(tbl))
	end

	local new = {}

	for i, v in pairs(tbl) do
		if (type(v) == 'table') then
			if (isType(v, Class)) then
				new[i] = deserialize(serialize(v))
			else
				new[i] = cloneTable(v, depth - 1)
			end
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

function mergeTables(out, ...)
	local tbls = {...}

	for _, tbl in ipairs(tbls) do
		for k, v in pairs(tbl) do
			if (out[k] == nil) then
				out[k] = v
			end
		end
	end

	return out
end

function mergeTablesRecursive(out, ...)
	local tbls = {...}

	for _, tbl in ipairs(tbls) do
		for k, v in pairs(tbl) do
			if (out[k] ~= nil) then
				if (type(out[k]) == 'table' and type(v) == 'table') then
					mergeTablesRecursive(out[k], v)
				else
					out[k] = v
				end
			end
		end
	end

	return out
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

local reservedWords = {
	['and'] = true,
	['break'] = true,
	['do'] = true,
	['else'] = true,
	['elseif'] = true,
	['end'] = true,
	['false'] = true,
	['for'] = true,
	['function'] = true,
	['if'] = true,
	['in'] = true,
	['local'] = true,
	['nil'] = true,
	['not'] = true,
	['or'] = true,
	['repeat'] = true,
	['return'] = true,
	['then'] = true,
	['true'] = true,
	['until'] = true,
	['while'] = true
}

--[[
	Serializes things.

	@param obj - thing to serialize
	@param compact - make smaller (without formatting)
]]
function serialize(obj, compact, indent, parents)
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

	if (typ == 'boolean') then
		return tostring(obj)
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

		if (isClass) then
			if (type(obj.serialize) == 'function') then
				data = obj:serialize()
			else
				error('Can not serialize type "' .. tostring(obj:getType()) .. '"')
			end
		elseif (isHardTable(obj)) then
			data = hardTableExport(obj)
		end

		local resultParts = {}
		local newLine = '\n' .. indent
		if (compact) then
			newLine = ''
			indent = ''
		end

		--TODO: maybe, someday
		if (isClass) then
			table.insert(resultParts, '<')
			table.insert(resultParts, obj.ClassName)
			table.insert(resultParts, '|')
		else
			table.insert(resultParts, '{')
		end

		local keys = sortedTableKeys(data)

		if (#keys > 0) then
			table.insert(resultParts, newLine)

			for i, key in pairs(keys) do
				local keyType = type(key)

				if (not compact) then
					table.insert(resultParts, '\t')
				end

				if (keyType == 'string') then
					local needsBraces = (key:find('^[%a_][%w_]*$') == nil) or (reservedWords[key] == true)

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
					table.insert(resultParts, serialize(key, compact, indent .. '\t', parents))
					table.insert(resultParts, ']')
				else
					error("Can't serialize key of type " .. keyType, 2)
				end
				if (compact) then
					table.insert(resultParts, '=')
				else
					table.insert(resultParts, ' = ')
				end

				table.insert(resultParts, serialize(data[key], compact, indent .. '\t', parents))
				if (not compact or i < #keys) then
					table.insert(resultParts, ',')
				end
				table.insert(resultParts, newLine)
			end
		end

		if (isClass) then
			table.insert(resultParts, '>')
		else
			table.insert(resultParts, '}')
		end

		parents[obj] = nil

		return table.concat(resultParts, '')
	end

	error('Unknown type to serialize "' .. typ .. '"', 2)
end

--[[
	Deserializer stuff:
]]
local function readIdentifier(str, head)
	local st, ed = str:find('^[%a_][%w_]*', head)

	if (st ~= nil) then
		return str:sub(st, ed), ed + 1
	end

	return nil
end

local function readString(str, head)
	local lim = #str
	if (head > lim) then
		return nil
	end
	local first = str:sub(head, head)
	local delim = nil
	if (first == '"') then
		delim = '"'
		head = head + 1
	elseif (first == "'") then
		delim = "'"
		head = head + 1
	end

	if (delim == nil) then
		return nil
	end

	local r = ''

	local next = str:sub(head, head)
	local start = head

	while (next ~= delim) do
		r = r .. next

		if (next == '\\') then
			head = head + 1
			if (head > lim) then
				error('unexpected eof when reading str')
			end
			r = r .. str:sub(head, head)
		end
		head = head + 1
		if (head > lim) then
			error('unexpected eof when reading str')
		end
		next = str:sub(head, head)
	end
	return r, head + 1
end

local function readWhitespace(str, head)
	local st, ed = str:find('^[ \t\n\r]+', head)
	if ((st == nil) or (ed < st)) then
		return nil
	end

	return str:sub(st, ed), ed + 1
end

local function tryReadWhitespace(str, head)
	local _, ed = readWhitespace(str, head)
	if (ed ~= nil) then
		head = ed
	end

	return head
end
local readNext

local function readIndexer(str, head)
	local start = head

	local chr = str:sub(head, head)
	if (chr ~= '[') then
		return readPlainString(str, head)
	end

	--skip [
	head = head + 1

	local typ, obj

	local allowedIndexTypes = {
		boolean = true,
		class = true,
		number = true,
		string = true,
		table = true
	}

	typ, obj, head = readNext(str, head)
	while ((typ ~= nil) and (typ == 'whitespace')) do
		typ, obj, head = readNext(str, head)
	end

	if (typ == nil) then
		error('could not read value of indexer at ' .. tostring(start))
	end

	if (not allowedIndexTypes[typ]) then
		error('invalid indexer type ' .. typ .. ' at ' .. tostring(start))
	end

	local ed

	_, ed = readWhitespace(str, head)
	if (ed ~= nil) then
		head = ed
	end

	local closeChr = str:sub(head, head)
	if (closeChr ~= ']') then
		error('unexpected ' .. closeChr .. ' at ' .. tostring(head) .. ' expected "]" to match "[" at ' .. tostring(start))
	end

	head = head + 1

	return obj, head
end

local function readNumber(str, head)
	local st, ed = str:find('^%-?%d+%.%d*', head)

	if (st == nil) then
		st, ed = str:find('^%-?%d+', head)
	end

	if (st == nil) then
		st, ed = str:find('^%-?%.%d+', head)
	end

	if (st ~= nil) then
		return tonumber(str:sub(st, ed)), ed + 1
	end

	return nil
end

local function readKeyValuePair(str, head)
	local ed, chr, typ, key, val

	chr = str:sub(head, head)

	if (chr == ',') then
		error('unexpected comma at ' .. tostring(head))
	end

	-- print('looking for kv pair')

	typ, key, head = readNext(str, head)

	if (key == nil) then
		-- print('found nothing')
		return nil
	end

	if (typ ~= 'identifier' and typ ~= 'indexer' and typ ~= 'string' and typ ~= 'number') then
		-- print('found ' .. typ .. " but we don't want it")
		return nil
	end

	-- print('found ' .. typ)
	local mustHaveValue = false
	if (typ == 'identifier' or typ == 'indexer') then
		mustHaveValue = true
	end

	head = tryReadWhitespace(str, head)

	chr = str:sub(head, head)
	if (mustHaveValue) then
		if (chr ~= '=') then
			error('missing value for key/value pair (missing "=" at ' .. tostring(head) .. ')')
		end
		head = head + 1
		-- print('looking for value')

		head = tryReadWhitespace(str, head)

		typ, val, head = readNext(str, head)

		-- print('found ', typ)
		if (val == nil) then
			error("couldn't read value in table at " .. tostring(head))
		end

		if (typ == 'identifier' or typ == 'indexer') then
			error('unexpected ' .. typ .. ' at ' .. tostring(head))
		end

		head = tryReadWhitespace(str, head)
	else
		val = key
		key = nil
	end

	chr = str:sub(head, head)
	-- print('chr is ' .. chr)
	if (chr == ',') then
		head = tryReadWhitespace(str, head + 1)
	end
	return key, val, head
end

local function readKeyValuePairs(str, head)
	local key, val, ed

	key, val, ed = readKeyValuePair(str, head)
	-- print('read keyvalue pair', serialize(key), serialize(val), ed)
	if (ed ~= nil) then
		head = ed
	end

	local result = {}
	while (val ~= nil) do
		if (key == nil) then
			table.insert(result, val)
		else
			result[key] = val
		end

		key, val, ed = readKeyValuePair(str, head)
		if (ed ~= nil) then
			head = ed
		end
	end

	return result, head
end
local function readTable(str, head)
	local start = head
	local chr = str:sub(head, head)

	if (chr ~= '{') then
		return nil
	end
	--skip {
	head = head + 1

	head = tryReadWhitespace(str, head)

	local data
	data, head = readKeyValuePairs(str, head)

	chr = str:sub(head, head)

	if (chr ~= '}') then
		error('unexpected ' .. chr .. ' when reading table, expected "}" at ' .. tostring(head))
	end

	return data, head + 1
end

local function readClass(str, head)
	local start = head
	local chr = str:sub(head, head)

	if (chr ~= '<') then
		return nil
	end
	--skip <
	head = head + 1

	head = tryReadWhitespace(str, head)

	local clazz

	clazz, head = readIdentifier(str, head)
	if (clazz == nil) then
		error('Could not read class name at ' .. tostring(head))
	end

	if (not isDefined(clazz)) then
		error('Could not deserialize class "' .. clazz .. '", class not found at ' .. tostring(head))
	end

	head = tryReadWhitespace(str, head)

	chr = str:sub(head, head)
	if (chr ~= '|') then
		error('unexpected "' .. chr .. '" when reading class, expected "|" at ' .. tostring(head))
	end
	head = head + 1

	head = tryReadWhitespace(str, head)

	local data
	data, head = readKeyValuePairs(str, head)

	chr = str:sub(head, head)

	if (chr ~= '>') then
		error('unexpected ' .. chr .. ' when reading table, expected ">" at ' .. tostring(head))
	end

	head = head + 1
	local clazzType = getfenv()[clazz]

	if (type(clazzType.Deserialize) == 'function') then
		return clazzType.Deserialize(data), head
	else
		return clazzType.ConvertToInstance(data), head
	end
end

local function readBoolean(str, head)
	local st, ed = str:find('^true%W', head)

	if (st ~= nil) then
		return true, ed
	end

	st, ed = str:find('^false%W', head)

	if (st ~= nil) then
		return false, ed
	end

	return nil
end

readNext = function(str, head)
	if (head > #str) then
		return nil
	end

	-- print('readNext', str:sub(head))
	local r, n

	local pats = {
		{pattern = '^{', typ = 'table'},
		{pattern = '^<', typ = 'class'},
		{pattern = '^%[', typ = 'indexer'},
		{pattern = '^%-?%d', typ = 'number'},
		{pattern = '^%-?%.%d', typ = 'number'},
		{pattern = '^true%W', typ = 'boolean'},
		{pattern = '^false%W', typ = 'boolean'},
		{pattern = '^[%a_][%w_]*', typ = 'identifier'},
		{pattern = "^'", typ = 'string'},
		{pattern = '^"', typ = 'string'},
		{pattern = '^[ \t\n\r]', typ = 'whitespace'}
	}

	local readers = {
		table = readTable,
		class = readClass,
		indexer = readIndexer,
		number = readNumber,
		identifier = readIdentifier,
		string = readString,
		whitespace = readWhitespace,
		boolean = readBoolean
	}

	local typ

	for _, pat in ipairs(pats) do
		if (str:find(pat.pattern, head)) then
			typ = pat.typ
			break
		end
	end

	if (readers[typ]) then
		return typ, readers[typ](str, head)
	end

	return nil, nil, head
end

function deserialize(str)
	local typ, obj, head = readNext(str, 1)
	return obj
end
