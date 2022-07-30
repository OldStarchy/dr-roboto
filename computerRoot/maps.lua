local version = '0.0.2'

local function startClient(name, sleepTime)
	if (_G._maps) then
		print('Maps already loaded')
		return
	end

	local context = {
		run = true,
		name = name,
		sleepTime = 1
	}
	_G._maps = context

	local function broadcastLocation()
		local x, y, z = gps.locate()
		if (x) then
			local packet = {
				type = 'reportLocation',
				location = {
					x = x,
					y = y,
					z = z
				},
				name = context.name
			}

			rednet.broadcast(packet, 'maps')

			context._status = 'broadcasting location'
		else
			context._status = 'No GPS'
		end
	end

	sleepTime = coalesce(sleepTime, 1)

	rednet.open('back')

	process.spawnProcess(
		function()
			while (context.run) do
				sleep(context.sleepTime)

				broadcastLocation()
			end

			rednet.close('back')
			if (_G._maps == context) then
				_G._maps = nil
			end
		end,
		'maps',
		true
	)
end

local function printLocations(locations)
	term.clear()
	term.setCursorPos(1, 1)

	print('Maps')
	print('-----')

	for name, location in pairs(locations) do
		local age = math.floor(os.time() - location.time)

		print(
			name ..
				': ' .. location.location.x .. ', ' .. location.location.y .. ', ' .. location.location.z .. ' (' .. age .. 's ago)'
		)
	end
end

local function startServer(modemSide)
	local reportedLocations = {}

	local function handlePacket(packet)
		if (packet.type == 'reportLocation') then
			reportedLocations[packet.name] = {
				location = packet.location,
				time = os.time()
			}
		end
	end

	rednet.close()
	rednet.open(modemSide)

	local run = true

	process.spawnProcess(
		function()
			while (run) do
				local id, message = rednet.receive('maps')
				if (id) then
					handlePacket(message)
				end
			end
		end,
		'maps host receiver',
		true
	)

	-- send data back to clients
	process.spawnProcess(
		function()
			while (run) do
				sleep(1)

				local packet = {
					type = 'reportLocations',
					locations = reportedLocations
				}

				rednet.broadcast(packet, 'maps')
			end
		end,
		'maps host broadcast',
		true
	)

	while (run) do
		os.startTimer(1)
		local event = os.pullEventRaw()
		if (event == 'terminate') then
			print('terminating')
			run = false
		end

		printLocations(reportedLocations)
	end

	rednet.close()
end

local function watchLocations()
	local run = true

	local reportedLocations = {}

	local function handlePacket(packet)
		if (packet.type == 'reportLocations') then
			reportedLocations = packet.locations
		end
	end

	local termWidth, termHeight = term.getSize()

	local canvas = Canvas(termWidth, termHeight - 1)

	local trail = {}
	term.clear()

	function countLocations()
		local count = 0
		for _, _ in pairs(reportedLocations) do
			count = count + 1
		end
		return count
	end

	local zoom = 1
	local trailsEnabled = false
	local maxTrail = nil

	local x, y, z

	local locator =
		process.spawnProcess(
		function()
			while (run) do
				sleep(0.2)

				x, y, z = gps.locate()
			end
		end,
		'maps watch locator',
		true
	)

	local renderLoop =
		process.spawnProcess(
		function()
			term.setCursorPos(1, 1)
			term.clearLine()
			term.write('Maps (' .. countLocations() .. ') scale = ' .. zoom)

			while (run) do
				sleep(0.2)
				term.setCursorPos(1, 1)
				term.clearLine()
				term.write('Maps (' .. countLocations() .. ') scale = ' .. zoom)

				if (x == nil) then
					print()
					print('No GPS')
					print(math.random(1, 100))
					print(x, y, z)
				else
					if (trailsEnabled) then
						local lastTrail = trail[#trail]
						if (not lastTrail or lastTrail.x ~= x or lastTrail.y ~= y or lastTrail.z ~= z) then
							table.insert(
								trail,
								{
									x = x,
									y = y,
									z = z
								}
							)
						end
						if (maxTrail ~= nil and #trail > maxTrail) then
							table.remove(trail, 1)
						end
					end
					canvas:fill(false)
					canvas:save()
					canvas.transform:translate(canvas.width / 2, canvas.height / 2)
					local scale = math.pow(1.2, zoom)
					canvas.transform:scale(scale, scale)
					canvas.transform:translate(-x, -z)

					for name, location in pairs(reportedLocations) do
						canvas:set(location.location.x, location.location.z, true)
					end

					local last = nil
					for _, location in ipairs(trail) do
						if (location.x) then
							if (last ~= nil) then
								canvas:line(last.x, last.z, location.x, location.z, true)
							end
							last = location
						else
							last = nil
						end
					end

					canvas:load()
					canvas:render(term, 1, 2)
				end
			end
		end,
		'maps watch render loop',
		true
	)

	local packetReceiver =
		process.spawnProcess(
		function()
			while (run) do
				local event, id, message, protocol = os.pullEventRaw('rednet_message')
				if (message) then
					handlePacket(message)
				end
			end
		end,
		'maps watch packet receiver',
		true
	)

	local inputHandler =
		process.spawnProcess(
		function()
			while (run) do
				local event, key = os.pullEventRaw('key')
				if (key == keys.q) then
					run = false
				elseif (key == keys.numPadAdd) then
					zoom = zoom + 1
				elseif (key == keys.numPadSubtract) then
					zoom = zoom - 1
				elseif (key == keys.t) then
					trailsEnabled = not trailsEnabled
					if (not trailsEnabled) then
						table.insert(trail, {})
					end
				elseif (key == keys.r) then
					trail = {}
				-- elseif (key == keys.m) then
				--  for this to work we need to pause the render loop
				-- 	maxTrail = tonumber(read())
				end
			end
		end,
		'maps input handler',
		true
	)

	process.spawnProcess(
		function()
			os.pullEventRaw('terminate')
			run = false
		end,
		'maps watch terminator',
		true
	)

	while (run) do
		sleep(1)
	end
end

local cli = Cli('maps', 'Starch Automation Maps', 'help')

cli:addAction(
	'help',
	function()
		cli:printUsage()
	end,
	{},
	'Shows this help text'
)

cli:addAction(
	'start',
	function(name)
		name = name or os.getComputerLabel()
		if (not name) then
			error('Name must be specified', 3)
		end
		print('Starch Automation Maps')
		print('Version: ' .. version)

		print('Starting maps client')
		startClient(name)
	end,
	{'name'},
	'Starts the maps client'
)

cli:addAction(
	'host',
	function(modemSide)
		print('Starch Automation Maps')
		print('Version: ' .. version)

		print('Starting maps')
		startServer(modemSide)
	end,
	{'modemSide'},
	'Start the server'
)

cli:addAction(
	'stop',
	function()
		if (_G._maps) then
			print('Stopping maps')

			_G._maps.run = false
			_G._maps = nil
			rednet.close()
		else
			print('Maps not running')
		end
	end,
	{},
	'Stops the maps client'
)

cli:addAction(
	'watch',
	function()
		watchLocations()
	end,
	{},
	'View the locations of all clients'
)
cli:run(...)
