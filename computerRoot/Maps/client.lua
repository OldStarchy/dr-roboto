local shared = require('shared')
local pidFile = fs.combine(os.getTempDir(), 'maps_client.pid')

local function savePid(pid)
	local file = fs.open(pidFile, 'w')
	file.write(pid)
	file.close()
end

local function removePidFile()
	fs.delete(pidFile)
end

local function getPid()
	local file = fs.open(pidFile, 'r')
	if (file) then
		local pid = tonumber(file.readAll())
		file.close()
		return pid
	end
	return nil
end

local function checkPid(pid)
	if (pid) then
		local process = process.getProcessById(pid)
		if (process) then
			return true
		end
	end
	return false
end

local function createLocationPacket()
	local x, y, z = gps.locate()

	if (x == nil) then
		return false
	end

	local name = os.getComputerLabel()

	local packet = {
		type = shared.PACKET_REPORT_LOCATION,
		location = {
			x = x,
			y = y,
			z = z
		},
		name = name
	}

	return packet
end

local function sendPacketToServer(packet)
	local modem = shared.findWirelessModem()
	local wasModemOpen = modem.isOpen(shared.CHANNEL)

	if (not wasModemOpen) then
		modem.open(shared.CHANNEL)
	end

	modem.transmit(shared.CHANNEL, shared.CHANNEL, packet)

	if (not wasModemOpen) then
		modem.close(shared.CHANNEL)
	end
end

local function client()
	local reportTimeoutInSeconds = 0.2
	local retryTimeoutMultiplier = 1

	while (true) do
		--pcall stops ctrl+t from stopping the program
		pcall(
			function()
				local packet = createLocationPacket()

				if (packet) then
					sendPacketToServer(packet)

					retryTimeoutMultiplier = 1
					sleep(reportTimeoutInSeconds)
				else
					sleep(reportTimeoutInSeconds * retryTimeoutMultiplier)
					retryTimeoutMultiplier = retryTimeoutMultiplier * 2
				end
			end
		)
	end
end

local function startClient()
	local pid = getPid()

	if (checkPid(pid)) then
		print('Maps already running (PID: ' .. pid .. ')')
		return
	end

	pid =
		process.spawnProcess(
		function()
			client()
			removePidFile()
		end,
		'Maps/client.lua',
		true
	)

	savePid(pid)
end

local args = {...}

if (#args == 0) then
	args = {'start'}
end

if (#args == 1) then
	if (args[1] == 'start') then
		print('Starting Maps client')
		startClient()
		return
	elseif (args[1] == 'stop') then
		local pid = getPid()

		if (pid) then
			process.kill(pid)
			removePidFile()
		else
			print('Maps not running')
		end
		return
	end
end

print('Usage: Maps/client [start|stop]')
