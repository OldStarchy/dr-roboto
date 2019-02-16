local bRunning = true
local tEnv = {
	['exit'] = function()
		bRunning = false
	end,
	['_echo'] = function(...)
		return ...
	end
}
setmetatable(tEnv, {__index = _G})

interactiveLua = function(...)
	local tArgs = {...}
	if #tArgs > 0 then
		print('This is an interactive Lua prompt.')
		print('To run a lua program, just type its name.')
		return
	end

	bRunning = true
	local tCommandHistory = {}

	if term.isColour() then
		term.setTextColour(colours.yellow)
	end
	print('Interactive Lua prompt.')
	print('Call exit() to exit.')
	term.setTextColour(colours.white)

	while bRunning do
		--if term.isColour() then
		--	term.setTextColour( colours.yellow )
		--end
		io.write('lua> ')
		--term.setTextColour( colours.white )

		local s = read()
		table.insert(tCommandHistory, s)

		local nForcePrint = 0
		local func, e = load(s, 'lua', 't', tEnv)
		local func2, e2 = load('return _echo(' .. s .. ');', 'lua', 't', tEnv)
		if not func then
			if func2 then
				func = func2
				e = nil
				nForcePrint = 1
			end
		else
			if func2 then
				func = func2
			end
		end

		if func then
			local tResults = {pcall(func)}
			if tResults[1] then
				local n = 1
				while (tResults[n + 1] ~= nil) or (n <= nForcePrint) do
					local value = tResults[n + 1]
					if type(value) == 'table' then
						local metatable = getmetatable(value)
						if type(metatable) == 'table' and type(metatable.__tostring) == 'function' then
							print(tostring(value))
						else
							local ok, serialised = pcall(textutils.serialise, value)
							if ok then
								print(serialised)
							else
								print(tostring(value))
							end
						end
					else
						print(tostring(value))
					end
					n = n + 1
				end
			else
				print('error: ' .. tostring(tResults[2]))
			end
		else
			print('error: ' .. tostring(e))
		end
	end
end
