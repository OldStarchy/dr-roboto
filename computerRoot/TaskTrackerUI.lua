startlocal()

VERSION = '0.0.1'

termWidth, termHeight = term.getSize()
shouldRun = false
shouldRedraw = false

function drawOpeningSplash()
	print('Starting Task Tracker UI v' .. VERSION)

	-- Pretend to load something
	local halfWidth = math.floor(termWidth / 2)
	term.write('Loading')
	term.write(string.rep(' ', halfWidth - #'Loading'))

	for i = 0, 5 do
		graphics:progressBar(i, 5)
		sleep(0.05)
	end

	-- Allow user to bask in the amasing load screen
	sleep(0.2)
end

function drawClosingSplash()
	term.clear()
	term.setCursorPos(1, 1)
	print('Thank you for using Task Tracker UI')
end

function drawFrame()
	graphics:drawRect(1, 1, termWidth, termHeight)

	graphics:invertColours()
	graphics:drawText(2, 1, '\145')
	graphics:invertColours()

	term.setTextColour(colours.white)
	term.setBackgroundColour(colours.black)

	graphics:drawText(3, 1, ' Task Tracker ' .. VERSION .. ' \157')
end

function draw()
	shouldRedraw = false

	graphics:clear()
	drawFrame()
end

function run()
	shouldRun = true
	shouldRedraw = true
	local frameTimeout = os.startTimer(0)
	while (shouldRun) do
		local event = {os.pullEventRaw()}

		-- print(tableToString(event))
		if (event[1] == 'timer') then
			if (event[2] == frameTimeout) then
				frameTimeout = os.startTimer(0.5)
			end
		end

		if (event[1] == 'terminate') then
			stop()
		end

		if (shouldRedraw) then
			draw()
		end
	end
end

function start()
	drawOpeningSplash()

	run()

	drawClosingSplash()
end

function stop()
	shouldRun = false
end

local trackerUI = endlocal()

trackerUI.start()
