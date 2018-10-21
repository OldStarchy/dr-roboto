Surface = Class(ITerm)
Surface.ClassName = 'Surface'

function Surface:constructor(width, height)
	self._width = assertType(width, 'int')
	self._height = assertType(coalesce(height, 0), 'int')
	self._maxY = 1

	self._cursorX = 1
	self._cursorY = 1

	self._foreground = colours.white
	self._background = colours.black

	self._textBuffer = {}
	self._foregroundBuffer = {}
	self._backgroundBuffer = {}

	self._cursorBlink = false
end

function Surface:_getLine(line)
	line = assertType(coalesce(line, self._cursorY), 'int')

	if (self._textBuffer[line] == nil) then
		self._textBuffer[line] = StringBuffer(' ', self._width)
		self._foregroundBuffer[line] = Buffer(colours.white, self._width)
		self._backgroundBuffer[line] = Buffer(colours.black, self._width)
	end

	return self._textBuffer[line], self._foregroundBuffer[line], self._backgroundBuffer[line]
end

function Surface:_prepareBlit(line, start, ed)
	local t, f, b = self:_getLine(line)

	local tstr = t:read(start, ed)
	local farr = f:read(start, ed)
	local barr = b:read(start, ed)

	local fstr = ''
	local bstr = ''

	for i = 1, #farr do
		fstr = fstr .. string.format('%x', math.logn(farr[i], 2))
		bstr = bstr .. string.format('%x', math.logn(barr[i], 2))
	end

	return tstr, fstr, bstr
end

function Surface:_onChange(lineNumbers)
	if (self._mirror == nil) then
		return
	end

	self:mirrorTo(self._mirror, self._mirrorX, self._mirrorY, lineNumbers)
end

function Surface:mirrorTo(term, x, y, lineNumbers)
	x = coalesce(x, 1)
	y = coalesce(y, 1)
	if (type(lineNumbers) ~= 'table' or #lineNumbers ~= 1 or lineNumbers[1] ~= 0) then
		term.setCursorBlink(false)
		self:blitTo(term, x, y, lineNumbers)
	end
	term.setCursorPos(x + self._cursorX - 1, y + self._cursorY - 1)
	term.setCursorBlink(self._cursorBlink)
end

function Surface:blitTo(term, x, y, lineNumbers)
	x = coalesce(x, 1)
	y = coalesce(y, 1)

	local w, h = self:getSize()
	if (h == 0) then
		h = self._maxY
	end
	local W, H = term.getSize()

	-- Sidenote; if lua started counting from 0 rather than 1, this would be slightly easier.

	-- Top left visible 'pixel' in this surface's coordinates
	local sx, sy
	if (x >= 1) then
		sx = 1
	else
		sx = 2 - x
	end
	if (y >= 1) then
		sy = 1
	else
		sy = 2 - y
	end

	-- Bottom right visible 'pixel' in this surface's coordinates
	local sx2, sy2
	if (x + w - 1 <= W) then
		sx2 = w
	else
		sx2 = W - x + 1
	end
	if (y + h - 1 <= H) then
		sy2 = h
	else
		sy2 = H - y + 1
	end

	-- Top left visible 'pixel' in the target term's coordinates
	local tx, ty
	if (x <= 1) then
		tx = 1
	else
		tx = x
	end
	if (y <= 1) then
		ty = 1
	else
		ty = y
	end

	-- The size of the actual visible area that should be drawn
	local dw = sx2 - sx + 1
	local dh = sy2 - sy + 1

	if (dw <= 0 or dh <= 0) then
		return
	end

	-- Redraw all lines by default
	if (lineNumbers == nil) then
		lineNumbers = {}
		for i = 1, dh do
			table.insert(lineNumbers, i)
		end
	end

	for _, i in pairs(lineNumbers) do
		term.setCursorPos(tx, ty + i - 1)

		local t, f, b = self:_prepareBlit(sy + i - 1, sx, sx2)
		term.blit(t, f, b)
	end
end

--[[
	Writes text to the current cursor position. Does not wrap over lines or advance cursor
]]
function Surface:write(str)
	local x = self._cursorX
	local y = self._cursorY

	if (y < 1) then
		return
	end

	if (self._height ~= 0 and y > self._height) then
		return
	end

	if (self._maxY < y) then
		self._maxY = y
	end

	text, fore, back = self:_getLine()
	text:write(str, x)
	fore:fill(self._foreground, x, x + #str)
	back:fill(self._background, x, x + #str)
	self._cursorX = self._cursorX + #str
	self:_onChange({y})
end

function Surface:scroll(amount)
	assertType(amount, 'int')

	if (amount < 0) then
		error('Cant scroll negative amounts', 2)
	end

	if (amount == 0) then
		return
	end

	if (self._height == 0) then
		return
	end

	for i = 1, self._height - amount do
		local t, f, b = self:_getLine(i + amount)
		self._textBuffer[i] = t
		self._foregroundBuffer[i] = f
		self._backgroundBuffer[i] = b
	end

	for i = self._height - amount + 1, self._height do
		self._textBuffer[i] = nil
		self._foregroundBuffer[i] = nil
		self._backgroundBuffer[i] = nil
	end

	self:_onChange()
end

function Surface:setCursorPos(x, y)
	self._cursorX, self._cursorY = assertType(x, 'int'), assertType(y, 'int')

	self:_onChange({0})
end

function Surface:setCursorBlink(blink)
	self._cursorBlink = assertType(blink, 'boolean')

	self:_onChange({0})
end

function Surface:getCursorPos()
	return self._cursorX, self._cursorY
end

function Surface:getSize()
	return self._width, self._height
end

function Surface:clear()
	self._textBuffer = {}
	self._foregroundBuffer = {}
	self._backgroundBuffer = {}

	self:_onChange()
end

function Surface:clearLine()
	self._textBuffer[self._cursorY] = nil
	self._foregroundBuffer[self._cursorY] = nil
	self._backgroundBuffer[self._cursorY] = nil

	self:_onChange({self._cursorY})
end

function Surface:setTextColour(col)
	self._foreground = assertType(col, 'int')
end

Surface.setTextColor = Surface.setTextColour

function Surface:setBackgroundColour(col)
	self._background = assertType(col, 'int')
end

Surface.setBackgroundColor = Surface.setBackgroundColour

function Surface:isColour()
	return true
end

Surface.isColor = Surface.isColour

function Surface:getTextColour()
	return self._foreground
end

Surface.getTextColor = Surface.getTextColour

function Surface:getBackgroundColour()
	return self._background
end

Surface.getBackgroundColor = Surface.getBackgroundColour

function Surface:blit(str, foreCols, backCols)
	local x = self._cursorX
	local y = self._cursorY

	if (y < 1) then
		return
	end

	if (self._height ~= 0 and y > self._height) then
		return
	end

	if (isType(foreCols, 'string')) then
		local temp = {}
		for i = 1, #foreCols do
			temp[i] = bit.blshift(1, tonumber('0x' .. foreCols:sub(i, i)))
		end
		foreCols = temp
	end

	assertType(foreCols, 'table')

	if (isType(backCols, 'string')) then
		local temp = {}
		for i = 1, #backCols do
			temp[i] = bit.blshift(1, tonumber('0x' .. backCols:sub(i, i)))
		end
		backCols = temp
	end

	assertType(backCols, 'table')

	text, fore, back = self:_getLine()
	text:write(str, x)
	fore:write(foreCols, x)
	back:write(backCols, x)

	self:_onChange({self._cursorY})
end

function Surface:startMirroring(newTerm, x, y)
	x = assertType(coalesce(x, 1), 'int')
	y = assertType(coalesce(y, 1), 'int')

	if (term == newTerm) then
		newTerm = term.native()
	end

	ITerm.assertImplementation(newTerm)

	self._mirror = newTerm
	self._mirrorX = x
	self._mirrorY = y
end

function Surface:getLastLine()
	return self._maxY
end

function Surface:asTerm()
	return {
		write = function(...)
			return self:write(...)
		end,
		scroll = function(...)
			return self:scroll(...)
		end,
		setCursorPos = function(...)
			return self:setCursorPos(...)
		end,
		setCursorBlink = function(...)
			return self:setCursorBlink(...)
		end,
		getCursorPos = function(...)
			return self:getCursorPos(...)
		end,
		getSize = function(...)
			return self:getSize(...)
		end,
		clear = function(...)
			return self:clear(...)
		end,
		clearLine = function(...)
			return self:clearLine(...)
		end,
		setTextColour = function(...)
			return self:setTextColour(...)
		end,
		setTextColor = function(...)
			return self:setTextColor(...)
		end,
		setBackgroundColour = function(...)
			return self:setBackgroundColour(...)
		end,
		setBackgroundColor = function(...)
			return self:setBackgroundColor(...)
		end,
		isColour = function(...)
			return self:isColour(...)
		end,
		isColor = function(...)
			return self:isColor(...)
		end,
		getTextColour = function(...)
			return self:getTextColour(...)
		end,
		getTextColor = function(...)
			return self:getTextColor(...)
		end,
		getBackgroundColour = function(...)
			return self:getBackgroundColour(...)
		end,
		getBackgroundColor = function(...)
			return self:getBackgroundColor(...)
		end,
		blit = function(...)
			return self:blit(...)
		end
	}
end
