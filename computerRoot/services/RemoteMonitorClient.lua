-- local surf = Surface(term.getSize(), 7)
-- surf:startMirroring(term.native(), 1, 1)

-- local surfTerm = surf:asTerm()

local side = peripheral.find('modem')
if (side == nil) then
	return
end
rednet.open(side)

while (true) do
	local ev = {os.pullEventRaw()}

	if (ev[1] == 'turtle_inventory' or ev[1] == 'turtle_moved') then
		rednet.broadcast(
			serialize(
				{
					inventory = inv:count(),
					location = mov:getPosition():toString(),
					fuel = turtle.getFuelLevel()
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
