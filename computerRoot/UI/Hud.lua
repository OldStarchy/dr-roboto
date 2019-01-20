Hud = Class()
Hud.ClassName = 'Hud'

function Hud:start()
	tterm = term.current()

	local w, h = tterm.getSize()

	local console = Surface(w - 6, h)

	tterm.clear()

	local graphics = Graphics(tterm)

	local f, b = graphics:getColours()
	graphics:setColours(colours.blue, b)
	for i = 1, h do
		graphics:drawText(w - 5, i, Pixel.compile(Pixel.LEFT))
	end

	graphics:drawText(w - 5, 5, Pixel.compile(Pixel.LEFT, Pixel.TOP))

	for i = 1, 5 do
		graphics:drawText(w - i + 1, 5, Pixel.compile(Pixel.TOP))
	end
	graphics:setColours(f, b)

	local positionChangedHdlr = function()
		local pos = Mov:getPosition()
		local f, b = graphics:getColours()
		graphics:setColours(colours.green, b)
		graphics:drawText(w - 4, 1, 'x')
		graphics:drawText(w - 4, 2, 'y')
		graphics:drawText(w - 4, 3, 'z')
		graphics:setColours(f, b)
		graphics:drawText(w - 3, 1, stringutil.lPad(tostring(pos.x), 4))
		graphics:drawText(w - 3, 2, stringutil.lPad(tostring(pos.y), 4))
		graphics:drawText(w - 3, 3, stringutil.lPad(tostring(pos.z), 4))
		graphics:drawText(w - 4, 4, stringutil.lPad(Position.directionNames[pos.direction], 5))
	end

	Mov:onPositionChanged(positionChangedHdlr)

	-- tterm.setCursorPos(1, 2)
	-- tterm.write(string.rep('\140', w))

	-- Run the shell
	console:startMirroring(tterm, 1, 1)
	term.redirect(console:asTerm())

	function self:stop()
		Mov:offPositionChanged(positionChangedHdlr)

		term.redirect(tterm)
	end

	positionChangedHdlr()

	--TODO: copy the code from the monitor program and redirect the shell to the console

	suppressMissingGlobalWarnings(true)

	local shellProc =
		process.spawnProcess(
		function()
			os.run({}, 'rom/programs/shell')
		end,
		'shell'
	)

	process.wait(shellProc)
end
