startlocal()

function startsWith(str, start)
	return start == '' or str:sub(1, #start) == start
end

function endsWith(str, ending)
	return ending == '' or str:sub(-(#ending)) == ending
end

function isLower(str)
	return str:lower() == str
end

function isUpper(str)
	return str:upper() == str
end

function lPad(str, size, char)
	assertType(str, 'string')
	assertType(size, 'int')
	char = assertType(coalesce(char, ' '), 'char')

	while (#str < size) do
		str = char .. str
	end

	return str
end

function rPad(str, size, char)
	assertType(str, 'string')
	assertType(size, 'int')
	char = assertType(coalesce(char, ' '), 'char')

	while (#str < size) do
		str = str .. char
	end

	return str
end

function split(str, pat)
	if (type(str) ~= 'string') then
		error('str must be string', 2)
	end
	local t = {}
	local fpat = '(.-)' .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= '' then
			table.insert(t, cap)
		end
		last_end = e + 1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

function join(tbl, glue)
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

function trim(str, char)
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

--for i=0,100 do stringutil.progressBar(i, 100); sleep(0.02) end
stringutil = endlocal()
