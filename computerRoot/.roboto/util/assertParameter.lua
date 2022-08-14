function assertParameter(obj, name, ...)
	if (type(name) ~= 'string') then
		error('assertParameter "name" must be a string', 2)
	end
	local typs = {...}

	for _, typ in ipairs(typs) do
		if (isType(obj, typ)) then
			return obj
		end
	end

	local typsMsg = ''
	for i, v in ipairs(typs) do
		if (typsMsg == '') then
			typsMsg = '"' .. tostring(v) .. '"'
		elseif (#typs < 3) then
			typsMsg = typsMsg .. ' or ' .. '"' .. tostring(v) .. '"'
		elseif (i == #typs) then
			typsMsg = typsMsg .. ', or ' .. '"' .. tostring(v) .. '"'
		else
			typsMsg = typsMsg .. ', ' .. '"' .. tostring(v) .. '"'
		end
	end

	local errmsg = 'Parameter "' .. name .. '" must be ' .. typsMsg .. ', was "' .. type(obj) .. '"'

	error(errmsg, 3)
end
