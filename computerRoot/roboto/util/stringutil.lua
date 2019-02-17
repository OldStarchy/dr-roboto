stringutil = {}

function stringutil.startsWith(str, start)
	return start == '' or str:sub(1, #start) == start
end

function stringutil.endsWith(str, ending)
	return ending == '' or str:sub(-(#ending)) == ending
end

function stringutil.isLower(str)
	return str:lower() == str
end

function stringutil.isUpper(str)
	return str:upper() == str
end

function stringutil.lPad(str, size, char)
	assertType(str, 'string')
	assertType(size, 'int')
	char = assertType(coalesce(char, ' '), 'char')

	while (#str < size) do
		str = char .. str
	end

	return str
end

function stringutil.rPad(str, size, char)
	assertType(str, 'string')
	assertType(size, 'int')
	char = assertType(coalesce(char, ' '), 'char')

	while (#str < size) do
		str = str .. char
	end

	return str
end

function stringutil.split(str, pat, removeEmpty)
	if (type(str) ~= 'string') then
		error('str must be string', 2)
	end
	local t = {}
	local fpat = '(.-)' .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= '' then
			if (cap ~= '' or not removeEmpty) then
				table.insert(t, cap)
			end
		end
		last_end = e + 1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		if (cap ~= '' or not removeEmpty) then
			table.insert(t, cap)
		end
	end
	return t
end

--TODO: just use table.concat
function stringutil.join(tbl, glue)
	if (tbl == nil) then
		error('Table expected, got nil', 2)
	end

	if (type(glue) ~= 'string') then
		error('string expected', 2)
	end

	if (#tbl == 0) then
		return ''
	end

	if (#tbl == 1) then
		return tbl[1]
	end

	local r = tbl[1]

	for i = 2, #tbl do
		r = r .. glue .. tbl[i]
	end

	return r
end

function stringutil.trim(str, char)
	if (char == nil) then
		char = ' '
	end

	local start = 1
	local ed = #str

	while (str:sub(start, start) == char) do
		start = start + 1
		if (start > ed) then
			return ''
		end
	end

	while (str:sub(ed, ed) == char) do
		ed = ed - 1
	end

	return str:sub(start, ed)
end

function stringutil.matchesPattern(str, pattern)
	return str:find(pattern) ~= nil
end
