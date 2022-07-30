local waitForInput = true

local termWidth, termHeight = term.getSize()

local canvas = Canvas(termWidth, termHeight - 1)

local width = canvas.width
local height = canvas.height

local function setTitle(title)
	term.setCursorPos(1, 1)
	term.clearLine()
	term.write(title)
end

local function render()
	canvas:render(term, 1, 2)
end

local function wait()
	if (waitForInput) then
		os.pullEvent('key')
	else
		sleep(1)
	end
end

local pixelDwell = 0
canvas.ev:on(
	'pixel_change',
	function()
		if (pixelDwell > 0) then
			render()
			sleep(pixelDell)
		end
	end
)

setTitle('Blank')

render()
wait()

setTitle('Filled')
canvas:fill(true)

render()
wait()

setTitle('Big X')
canvas:fill(false)
pixelDwell = 0
canvas:line(1, 1, width, height, true)
canvas:line(width, 1, 1, height, true)

render()
wait()

setTitle('Square')
canvas:fill(false)
pixelDwell = 0
canvas:square(1 * width / 3, 1 * height / 3, 2 * width / 3, 2 * height / 3, true)

render()
wait()

setTitle('Random lines')
canvas:fill(false)
pixelDwell = 0
local lineCount = math.random(1, 10)
local lines = {}
for i = 1, lineCount do
	local x1 = math.random(1, width)
	local y1 = math.random(1, height)
	local x2 = math.random(1, width)
	local y2 = math.random(1, height)
	lines[i] = {x1, y1, x2, y2}
end

for _, line in ipairs(lines) do
	canvas:line(line[1], line[2], line[3], line[4], true)
end

render()
wait()

function awaitAnimationFrame()
	local timer = os.startTimer(0)
	local clock = os.clock()

	while (true) do
		local event = {os.pullEvent()}
		if (event[1] == 'timer' and event[2] == timer) then
			return
		end
	end
end

setTitle('Rotation')
canvas:fill(false)
for r = 0, 360, 5 do
	canvas:fill(false)
	canvas:save()
	canvas.transform:translate(width / 2, height / 2)
	canvas.transform:rotate(r / 180 * math.pi)
	canvas.transform:translate(-width / 2, -height / 2)

	for _, line in ipairs(lines) do
		canvas:line(line[1], line[2], line[3], line[4], true)
	end

	canvas:load()
	render()
	awaitAnimationFrame()
end

setTitle('Circle')
canvas:fill(false)
pixelDwell = 0
local radius = math.floor(math.min(width, height) / 2) - 1
local x = math.floor(width / 2)
local y = math.floor(height / 2)

canvas:circle(x, y, radius, true)

render()
wait()

setTitle('All sorts of random shit')
canvas:fill(false)
pixelDwell = 0
local lineCount = math.random(1, 10)
local lines = {}
for i = 1, lineCount do
	local x1 = math.random(1, width)
	local y1 = math.random(1, height)
	local x2 = math.random(1, width)
	local y2 = math.random(1, height)
	lines[i] = {x1, y1, x2, y2}
end

local circleCount = 5
local circles = {}
for i = 1, circleCount do
	local radius = math.random(1, 10)
	local x = math.random(1, width)
	local y = math.random(1, height)
	circles[i] = {x, y, radius, true}
end

for _, line in ipairs(lines) do
	canvas:line(line[1], line[2], line[3], line[4], true)
end

for _, circle in ipairs(circles) do
	canvas:circle(circle[1], circle[2], circle[3], circle[4])
end

render()
wait()

setTitle('Rotation (again)')
canvas:fill(false)
for r = 0, 360, 5 do
	canvas:fill(false)
	canvas:save()
	canvas.transform:translate(width / 2, height / 2)
	canvas.transform:rotate(r / 180 * math.pi)
	canvas.transform:translate(-width / 2, -height / 2)

	for _, line in ipairs(lines) do
		canvas:line(line[1], line[2], line[3], line[4], true)
	end

	for _, circle in ipairs(circles) do
		canvas:circle(circle[1], circle[2], circle[3], circle[4])
	end

	canvas:load()
	render()
	awaitAnimationFrame()
end
