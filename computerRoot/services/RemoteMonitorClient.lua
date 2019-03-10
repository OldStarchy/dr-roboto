-- local surf = Surface(term.getSize(), 7)
-- surf:startMirroring(term.native(), 1, 1)

-- local surfTerm = surf:asTerm()

rednet.open('right')

while (true) do
	local ev = {os.pullEventRaw()}

	if (ev[1] == 'turtle_inventory' or ev[1] == 'turtle_moved') then
		local d = {}

		runWithLogging(
			function()
				if (isDefined('broadcastData')) then
					for i, v in pairs(broadcastData) do
						if (type(v) ~= 'function') then
							d[i] = v
						end
					end
				end
			end
		)

		rednet.broadcast(
			serialize(
				{
					inventory = inv:count(),
					location = mov:getPosition():toString(),
					fuel = turtle.getFuelLevel(),
					data = d
				}
			)
		)
		print(serialize(ev[1]))
	end
	-- local cterm = term.current()
	-- term.redirect(surfTerm)
	-- term.clear()
	-- term.setCursorPos(1, 1)
	-- print(tableToString(ev))
	-- term.redirect(cterm)
	-- term.setCursorBlink(true)
end
