includeOnce './ITerm'
includeOnce '../Math/Matrix'
includeOnce './Pixel'

Canvas = Class()
Canvas.ClassName = 'Canvas'

function Canvas:constructor(charWidth, charHeight)
	self.charWidth = charWidth
	self.charHeight = charHeight
	self.width = charWidth * 2
	self.height = charHeight * 3
	self.ev = EventManager()
	self.transform = Matrix()
	self._transforms = {}

	-- 2d array, [y][x] 1's or 0's, depending if that subpixel is filled or not.
	self.subpixelBuffer = {}

	for y = 1, self.height do
		self.subpixelBuffer[y] = {}
		for x = 1, self.width do
			self.subpixelBuffer[y][x] = 0
		end
	end
end

function Canvas:save()
	table.insert(self._transforms, self.transform:clone())
end

function Canvas:load()
	self.transform = table.remove(self._transforms)
end

function Canvas:resetTransform()
	self.transform = Matrix()
end

function Canvas:_applyTransform(x, y)
	return self.transform:transformPoint(x, y)
end

function Canvas:set(x, y, filled)
	x = assertType(x, 'number')
	y = assertType(y, 'number')
	assertType(filled, 'boolean')

	x, y = self:_applyTransform(x, y)

	x = math.floor(x)
	y = math.floor(y)

	if x < 1 or x > self.width or y < 1 or y > self.height then
		return
	end

	--TODO: remove this check it should be impossible to fail here but it has done
	if (self.subpixelBuffery[y]) then
		self.subpixelBuffer[y][x] = filled and 1 or 0
	end

	self.ev:trigger('pixel_change')
end

function Canvas:fill(filled)
	assertType(filled, 'boolean')

	for _y = 1, self.height do
		for _x = 1, self.width do
			self.subpixelBuffer[_y][_x] = filled and 1 or 0
		end
	end

	self.ev:trigger('pixel_change')
	self.ev:trigger('change')
end

function Canvas:line(x1, y1, x2, y2, filled)
	x1 = assertType(x1, 'number')
	y1 = assertType(y1, 'number')
	x2 = assertType(x2, 'number')
	y2 = assertType(y2, 'number')
	assertType(filled, 'boolean')

	x1, y1 = self:_applyTransform(x1, y1)
	x2, y2 = self:_applyTransform(x2, y2)

	x1 = math.floor(x1)
	y1 = math.floor(y1)
	x2 = math.floor(x2)
	y2 = math.floor(y2)

	self:save()
	self:resetTransform()

	local dx = math.abs(x2 - x1)
	local dy = math.abs(y2 - y1)
	local sx = x1 < x2 and 1 or -1
	local sy = y1 < y2 and 1 or -1
	local err = dx - dy
	local e2 = 0
	local x = x1
	local y = y1

	while true do
		self:set(x, y, filled)
		if x == x2 and y == y2 then
			break
		end
		e2 = 2 * err
		if e2 > -dy then
			err = err - dy
			x = x + sx
		end
		if e2 < dx then
			err = err + dx
			y = y + sy
		end
	end

	self:load()
	self.ev:trigger('change')
end

function Canvas:square(x1, y1, x2, y2, filled)
	x1 = math.floor(assertType(x1, 'number'))
	y1 = math.floor(assertType(y1, 'number'))
	x2 = math.floor(assertType(x2, 'number'))
	y2 = math.floor(assertType(y2, 'number'))
	assertType(filled, 'boolean')

	local xMin = math.min(x1, x2)
	local xMax = math.max(x1, x2)
	local yMin = math.min(y1, y2)
	local yMax = math.max(y1, y2)

	for i = yMin, yMax do
		for j = xMin, xMax do
			self:set(j, i, filled)
		end
	end

	self.ev:trigger('change')
end

function Canvas:circle(x, y, radius, filled)
	x = math.floor(assertType(x, 'number'))
	y = math.floor(assertType(y, 'number'))
	radius = math.floor(assertType(radius, 'number'))
	assertType(filled, 'boolean')

	for i = 0, radius do
		local r = math.floor(math.sqrt(radius * radius - i * i))
		self:line(x + i, y - r, x + i, y + r, true)
		self:line(x - i, y - r, x - i, y + r, true)
	end
end

function Canvas:render(term, x, y)
	assertType(term, ITerm)
	assertType(x, 'number')
	assertType(y, 'number')

	local foreground, background = term:getTextColor(), term:getBackgroundColor()

	local lastInverted = false
	for _y = 1, self.charHeight do
		local top = self.subpixelBuffer[_y * 3 - 2]
		local middle = self.subpixelBuffer[_y * 3 - 1]
		-- if (_y * 3 + 1 > #self.subpixelBuffer) then
		-- 	term.setCursorPos(1, 1)
		-- 	print('_y is ' .. _y .. ' and #self.subpixelBuffer is ' .. #self.subpixelBuffer)
		-- 	print('_y * 3 + 1 is ' .. _y * 3 + 1)
		-- 	print('self.charheight is ' .. self.charHeight)
		-- 	print('self.height is ' .. self.height)
		-- 	read()
		-- end
		local bottom = self.subpixelBuffer[_y * 3]

		for _x = 1, self.charWidth do
			local topLeft = top[_x * 2 - 1] * Pixel.TOP_LEFT
			local topRight = top[_x * 2] * Pixel.TOP_RIGHT
			local middleLeft = middle[_x * 2 - 1] * Pixel.MIDDLE_LEFT
			local middleRight = middle[_x * 2] * Pixel.MIDDLE_RIGHT
			local bottomLeft = bottom[_x * 2 - 1] * Pixel.BOTTOM_LEFT
			local bottomRight = bottom[_x * 2] * Pixel.BOTTOM_RIGHT

			local pixel = Pixel.Compile(topLeft, topRight, middleLeft, middleRight, bottomLeft, bottomRight)

			term.setCursorPos(x + _x - 1, y + _y - 1)
			if (lastInverted ~= pixel.inverted) then
				if (pixel.inverted) then
					term.setTextColor(background)
					term.setBackgroundColor(foreground)
				else
					term.setTextColor(foreground)
					term.setBackgroundColor(background)
				end
				lastInverted = pixel.inverted
			end

			term.write(pixel.char)
		end
	end

	term.setTextColor(foreground)
	term.setBackgroundColor(background)
end

local function invertTermColors(term)
	local oldBackground = term.getBackgroundColor()
	local oldText = term.getTextColor()
	term.setBackgroundColor(oldText)
	term.setTextColor(oldBackground)
end
