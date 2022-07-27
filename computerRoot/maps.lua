local version = '0.0.2'

local function startClient(name, sleepTime)
	if (_G._maps) then
		print('Maps already loaded')
		return
	end

	local context = {
		run = true,
		name = name,
		sleepTime = 0.2
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
		'maps host',
		true
	)

	-- send data back to clients
	process.spawnProcess(
		function()
			while (run) do
				sleep(0.2)

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
	local context = _G._maps
	if (context == nil) then
		print('Maps not running')
		print('Run `maps start` to start it')
		return
	end

	local reportedLocations = {}

	local function handlePacket(packet)
		if (packet.type == 'reportLocations') then
			reportedLocations = packet.locations
		end
	end

	process.spawnProcess(
		function()
			while (context.run) do
				local id, message = rednet.receive('maps')
				if (id) then
					handlePacket(message)
				end
			end
		end,
		'maps host',
		true
	)

	local run = true
	while (run) do
		os.startTimer(1)
		local event = os.pullEventRaw()
		if (event == 'terminate') then
			print('terminating')
			run = false
		end

		printLocations(reportedLocations)
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
