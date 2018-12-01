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

--for i=0,100 do stringutil.progressBar(i, 100); sleep(0.02) end
stringutil = endlocal()
