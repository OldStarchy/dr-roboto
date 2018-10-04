Surface = Class()
Surface.ClassName = 'Surface'

function Surface:constructor(width, height)
	self._width = width
	self._height = height

	self._buffer = {}
	self._cursorX = 1
	self._cursorY = 1

	self._foreground = colours.white
	self._background = colours.black

	self._outputX = nil
	self._outputY = nil
	self._outputTerm = nil
end

function Surface:getSize()
	return self._width, self._height
end

function Surface:getTextColour()
	return self._foreground
end
function Surface:setTextColour(colour)
	self._foreground = colour
end
Surface.getTextColor = Surface.getTextColour
Surface.setTextColor = Surface.setTextColour

function Surface:getBackgroundColour()
	return self._background
end
function Surface:setBackgroundColour(colour)
	self._background = colour
end
Surface.getBackgroundColor = Surface.getBackgroundColour
Surface.setBackgroundColor = Surface.setBackgroundColour

function Surface:getCursorPos()
	return self._cursorX, self._cursorY
end
function Surface:setCursorPos(x, y)
	self._cursorX, self._cursorY = x, y
end

function Surface:getCursorBlink()
	return self._blink
end
function Surface:setCursorBlink(blink)
	self._blink = blink

	if (self._outputTerm ~= nil) then
		self._outputTerm.setCursorBlink(blink)
	end
end

function Surface:write(str)
	local lim = #str

	for i = 1, lim do
		local char = str:sub(i, i)

		if (char == '\n') then
			self:_crlf()
		else
			self:_getLine(self._cursorY)[self._cursorX] = {
				foreground = self._foreground,
				background = self._background,
				character = char
			}
		end

		self:_advance()
	end

	if (self._outputTerm ~= nil) then
		self:drawTo(self._outputX, self._outputY, self._outputTerm)
	end
end

function Surface:outputTo(term, x, y)
	if (x == nil) then
		x = 1
	end
	if (y == nil) then
		y = 1
	end
	self._outputX = x
	self._outputY = y
	self._outputTerm = term
end

function Surface:scroll(count)
	for i = 1, self._height - count do
		self._buffer[i] = self._buffer[i + count]
	end

	for i = self._height - count + 1, self._height do
		self._buffer[i] = {}
	end
end

function Surface:drawTo(x, y, term)
	local w, h = term.getSize()
	local maxW = math.max(self._width, w - x + 1)
	local maxH = math.max(self._height, h - y + 1)

	local f = term.getTextColour()
	local b = term.getBackgroundColour()
	local sf, sb = f, b
	for i = 1, maxH do
		local line = self:_getLine(i)

		for j = 1, maxW do
			local chr = line[j]
			if (chr ~= nil) then
				if (f ~= chr.foreground) then
					f = chr.foreground
					term.setTextColour(f)
				end

				if (b ~= chr.background) then
					b = chr.background
					term.setBackgroundColour(f)
				end

				term.setCursorPos(x + j - 1, y + i - 1)
				term.write(chr.character)
			else
				term.setCursorPos(x + j - 1, y + i - 1)
				term.write(' ')
			end
		end
	end

	term.setTextColour(sf)
	term.setBackgroundColour(sb)
end

function Surface:isColour()
	return true
end

Surface.isColor = Surface.isColour

function Surface:asTerm()
	return setmetatable(
		{},
		{
			__index = function(tbl, key)
				if (self[key]) then
					if (type(self[key]) == 'function') then
						return function(...)
							return self[key](self, ...)
						end
					else
						return self[key]
					end
				end
			end
		}
	)
end

function Surface:_advance()
	self._cursorX = self._cursorX + 1

	if (self._cursorX > self._width) then
		self:_crlf()
	end
end

function Surface:_crlf()
	self._cursorX = 1

	if (self._cursorY < self._height) then
		self._cursorY = self._cursorY + 1
	else
		self:scroll()
	end
end

function Surface:_getLine(row)
	if (self._buffer[row] == nil) then
		self._buffer[row] = {}
	end

	return self._buffer[row]
end

if (rawget(_G, 'term') ~= nil) then
	local nativetermredirect = term.redirect
	term.redirect = function(target)
		if (isType(target, Surface)) then
			return nativetermredirect(target:asTerm())
		else
			return nativetermredirect(target)
		end
	end
end
