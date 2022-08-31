includeOnce 'lib/Graphics/Surface'

local Button = Class()
Button.ClassName = 'Button'

function Button:constructor(x, y, width, height, text, onClick)
	self._x = assertParameter(x, 'x', 'number')
	self._y = assertParameter(y, 'y', 'number')
	self._width = assertParameter(width, 'width', 'number')
	self._height = assertParameter(height, 'height', 'number')
	self._text = assertParameter(text, 'text', 'string')
	self._onClick = assertParameter(onClick, 'onClick', 'function')
end

function Button:contains(x, y)
	assertParameter(x, 'x', 'number')
	assertParameter(y, 'y', 'number')

	return (x >= self._x) and (x <= self._x + self._width - 1) and (y >= self._y) and (y <= self._y + self._height - 1)
end

function Button:onClick()
	self._onClick()
end

local MouseInput = Class(AbortSignal)
MouseInput.ClassName = 'MouseInput'

MouseInput.MB_LEFT = 1
MouseInput.MB_RIGHT = 2
MouseInput.MB_MIDDLE = 3

function MouseInput:constructor()
	AbortSignal.constructor(self)
	self._dragStart = {}
	self._mouseButtons = {}

	self._buttons = {}

	local this = self
	self.handleMouseDown = function(button, x, y)
		this._mouseButtons[button] = true
		this._dragStart[button] = {x = x, y = y}
	end

	self.handleMouseUp = function(button, x, y)
		if (button == MouseInput.MB_LEFT) then
			local start = this._dragStart[button]
			for _, button in ipairs(self._buttons) do
				if (button:contains(start.x, start.y) and button:contains(x, y)) then
					button:onClick()
				end
			end
		end

		this._mouseButtons[button] = false
		this._dragStart[button] = nil
	end

	os.ev:on('mouse_click', self.handleMouseDown, self)
	os.ev:on('mouse_up', self.handleMouseUp, self)
	return self
end

function MouseInput:registerButton(button)
	assertParameter(button, 'button', Button)

	table.insert(self._buttons, button)
end

function MouseInput:unregisterButton(button)
	assertParameter(button, 'button', Button)

	for i, b in ipairs(self._buttons) do
		if (b == button) then
			table.remove(self._buttons, i)
			break
		end
	end
end

function MouseInput:renderButtons()
	local bgColor = term.getBackgroundColor()
	local textColor = term.getTextColor()

	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)

	for _, button in ipairs(self._buttons) do
		for y = button._y, button._y + button._height - 1 do
			term.setCursorPos(button._x, y)
			term.write(string.rep(' ', button._width))
		end

		term.setCursorPos(
			button._x + math.floor((button._width - #button._text) / 2),
			button._y + math.floor(button._height / 2)
		)
		term.write(button._text)
	end

	term.setBackgroundColor(bgColor)
	term.setTextColor(textColor)
end

local width, height = term.getSize()
local output = Surface(width, height - 3)

output:startMirroring(term.current(), 1, 4)

local m = MouseInput()
local clickCount = 0
local b =
	Button(
	1,
	1,
	10,
	3,
	'Click Me',
	function()
		local old = term.redirect(output:asTerm())
		clickCount = clickCount + 1
		print('Clicked ' .. clickCount .. ' times')
		term.redirect(old)
	end
)

m:registerButton(b)

local quitButton =
	Button(
	width - 9,
	1,
	10,
	3,
	'Quit',
	function()
		m:abort()
	end
)
m:registerButton(quitButton)

m:renderButtons()

while (not m:wasAborted()) do
	local event = os.pullEventRaw()
	if (event == 'terminate') then
		m:abort()
	end
end

term.setCursorPos(1, height)
