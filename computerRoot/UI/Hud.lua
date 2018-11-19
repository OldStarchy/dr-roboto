Hud = Class()
Hud.ClassName = 'Hud'

function Hud:start()
	tterm = term.current()

	local w, h = tterm.getSize()

	local console = Surface(w - 6, h)

	tterm.clear()

	local graphics = Graphics(tterm)

	for i = 1, h do
		graphics:drawText(w - 5, i, '\149')
	end

	-- graphics:invertColours()
	graphics:drawText(w - 5, 5, '\150')
	-- graphics:invertColours()

	for i = 1, 5 do
		graphics:drawText(w - i + 1, 5, '\131')
	end

	local positionChangedHdlr = function()
		local pos = Mov:getPosition()
		graphics:drawText(w - 4, 1, 'x' .. stringutil.lPad(tostring(pos.x), 4))
		graphics:drawText(w - 4, 2, 'y' .. stringutil.lPad(tostring(pos.y), 4))
		graphics:drawText(w - 4, 3, 'z' .. stringutil.lPad(tostring(pos.z), 4))
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
end
