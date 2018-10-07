Graphics = Class()
Graphics.ClassName = 'Graphics'

function Graphics:constructor(term)
	self._term = term
end

function Graphics:drawText(x, y, str)
	self._term.setCursorPos(x, y)
	self._term.write(str)
end

function Graphics:progressBar(progress, max, row, startCol, endCol)
	if (row == nil) then
		row = select(2, self._term.getCursorPos())
	end

	if (startCol == nil) then
		startCol = 1
	end

	if (endCol == nil) then
		endCol = self._term.getSize()
	end

	if (startCol == endCol) then
		error("startCol and endCol can't be equal", 2)
	end

	if (startCol > endCol) then
		startCol, endCol = endCol, startCol
	end

	if (progress > max) then
		progress = max
	end

	local innerWidth = endCol - startCol - 1

	if (innerWidth == 0) then
		self:drawText(startCol, row, '[]')
		return
	end

	local dots = math.floor(progress * innerWidth / max)
	local spaces = innerWidth - dots

	self:drawText(startCol, row, '[' .. string.rep('.', dots) .. string.rep(' ', spaces) .. ']')
end

function Graphics:setColours(foreground, background)
	self._term.setTextColour(foreground)
	self._term.setBackgroundColour(background)
end

function Graphics:invertColours()
	self:setColours(self._term.getBackgroundColour(), self._term.getTextColour())
end

function Graphics:fillRect(startCol, startRow, endCol, endRow, char)
	startCol, endCol = math.minMax(startCol, endCol)
	startRow, endRow = math.minMax(startRow, endRow)

	local str = string.rep(char, endCol - startCol + 1)
	for i = startRow, endRow do
		self:drawText(startCol, startRow, str)
	end
end

function Graphics:drawRect(startCol, startRow, endCol, endRow, chars)
	local innerWidth = endCol - startCol - 1
	local innerHeight = endRow - startRow - 1

	if (chars == nil) then
		chars = {
			tl = '\152',
			t = '\140',
			tr = '\155',
			r = '\149',
			br = '\134',
			b = '\140',
			bl = '\137',
			l = '\149'
		}
	end

	-- chars = {
	-- 	tl = '[',
	-- 	t = '=',
	-- 	tr = ']',
	-- 	r = 'r',
	-- 	br = ')',
	-- 	b = '_',
	-- 	bl = '(',
	-- 	l = 'l'
	-- }

	self:drawText(startCol, startRow, chars.tl .. string.rep(chars.t, innerWidth))
	self:invertColours()
	self:drawText(endCol, startRow, chars.tr)

	for i = startRow + 1, endRow - 1 do
		self:invertColours()
		self:drawText(startCol, i, chars.l)

		self:invertColours()
		self:drawText(endCol, i, chars.r)
	end

	self:invertColours()
	self:drawText(startCol, endRow, chars.bl .. string.rep(chars.b, innerWidth))
	self:drawText(endCol, endRow, chars.br)
end

function Graphics:clear()
	self._term.clear()
end

function Graphics:drawSurface(x, y, surface)
	assertType(surface, Surface)

	surface:drawTo(x, y, self._term)
end
