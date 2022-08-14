includeOnce 'lib/Graphics/Surface'

--[[
	Runs a command to an offscreen buffer, then shows the output in a scrollable pane.

	down, j, enter	- scroll down 1 line
	up, k			- scroll up 1 line
	pageDown		- scroll down 1 page
	pageUp			- scroll up 1 page
	home			- go to top
	end				- go to bottom
	q				- quit
]]
local current = term.current()
local hw, hh = term.getSize()
local surface = Surface(hw, 10000)

term.redirect(surface:asTerm())
local oldread = read
_G.read = function()
	return ''
end

if (isDefined('shell')) then
	shell.run(...)
else
	local args = {...}
	local fname = table.remove(args, 1)
	loadfile(fname)(unpack(args))
end

_G.read = oldread
term.redirect(current)

local lastLine = surface:getLastLine()
local lim = lastLine - hh + 2

if (lastLine < hh) then
	surface:mirrorTo(term)
	return
end

if (lim <= 0) then
	lim = 1
end

local head = 1

local function scrollUp(amount)
	amount = coalesce(amount, 1)
	head = head - amount
	if (head < 1) then
		head = 1
	end
end
local function scrollDown(amount)
	amount = coalesce(amount, 1)
	head = head + amount
	if (head > lim) then
		head = lim
	end
end
local function scrollPageUp()
	scrollUp(hh - 2)
end

local function scrollPageDown()
	scrollDown(hh - 2)
end

local abortSignal = AbortSignal()
local run = true

os.ev:on(
	'key',
	function(key)
		if (key == keys.q) then
			run = false
		elseif (key == keys.down or key == keys.j or key == keys.enter) then
			scrollDown()
		elseif (key == keys.up or key == keys.k) then
			scrollUp()
		elseif (key == keys.pageDown) then
			scrollPageDown()
		elseif (key == keys.pageUp) then
			scrollPageUp()
		elseif (key == keys.home) then
			head = 1
		elseif (key == keys['end']) then
			head = lim
		end

		os.queueEvent('less.render')
	end,
	abortSignal
)

os.ev:on(
	'mouse_scroll',
	function(scroll, x, y)
		if (scroll < 0) then
			scrollUp(3)
		else
			scrollDown(3)
		end

		os.queueEvent('less.render')
	end,
	abortSignal
)

xpcall(
	function()
		while run do
			surface:mirrorTo(term, 1, 2 - head)

			local percent = stringutil.lPad(tostring(math.floor(100 * head / lim)), 3)
			term.setCursorPos(1, hh)

			term.write('Navigate with arrows, q to exit  ')
			term.setCursorPos(hw - 5, hh)
			term.write('[' .. tostring(percent) .. '%]')

			os.pullEvent('less.render')
		end

		abortSignal:abort()
	end,
	function()
		abortSignal:abort()
	end
)

term.scroll(1)
term.setCursorPos(1, hh)
