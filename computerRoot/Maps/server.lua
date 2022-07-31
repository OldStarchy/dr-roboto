local shared = require('shared')

local function createLocationPacket(reportedLocation)
	local id = reportedLocation.id
	local name = reportedLocation.name
	local age = shared.calculateAge(reportedLocation.time)
	local location = reportedLocation.location

	return {
		type = shared.PACKET_FORWARD_LOCATION,
		id = id,
		name = name,
		age = age,
		location = location
	}
end

local function forwardReportedLocation(reportedLocation)
	local packet = createLocationPacket(reportedLocation)

	local modem = shared.findWirelessModem()

	modem.transmit(shared.CHANNEL, shared.CHANNEL, packet)
end

local run = true
local modem = shared.findWirelessModem()
local nextClientId = shared.idCounter()
local reportedLocations = {}

local function handlePacket(packet)
	if (packet.type == shared.PACKET_REPORT_LOCATION) then
		if (reportedLocations[packet.name] == nil) then
			reportedLocations[packet.name] = {
				id = nextClientId(),
				name = packet.name
			}
		end

		reportedLocations[packet.name].location = packet.location
		reportedLocations[packet.name].time = os.epoch('utc')

		shared.printReportedLocation(reportedLocations[packet.name], 2, true)
	end
end

if (not modem) then
	print('Could not find wireless modem')
	return
end

local wasModemOpen = modem.isOpen(shared.CHANNEL)

if (not wasModemOpen) then
	modem.open(shared.CHANNEL)
end

local uiProcess =
	process.spawnProcess(
	function()
		term.clear()
		shared.printHeader('Maps', 'press "q" to quit')

		while (run) do
			local event = {os.pullEventRaw()}

			if (event[1] == 'terminate' or (event[1] == 'char' and event[2] == 'q')) then
				run = false
				break
			end

			if (event[1] == 'modem_message') then
				local _, side, channel, replyChannel, message, distance = unpack(event)

				if (channel == shared.CHANNEL) then
					handlePacket(message)
				end
			end
		end

		term.setCursorPos(1, 3 + nextClientId())
	end,
	'Maps Server UI',
	false
)

local rerenderAllProcess =
	process.spawnProcess(
	function()
		while (run) do
			for name, reportedLocation in pairs(reportedLocations) do
				shared.printReportedLocation(reportedLocation, 2, true)

				if (shared.calculateAge(reportedLocation.time) > shared.MAX_AGE) then
					reportedLocations[name] = nil
				end
			end
			sleep(1)
		end
	end,
	'Maps Server Rerenderer',
	true
)

local forwardingProcess =
	process.spawnProcess(
	function()
		while (run) do
			local event = {os.pullEventRaw()}

			for _, reportedLocation in pairs(reportedLocations) do
				forwardReportedLocation(reportedLocation)
			end

			sleep(0.2)
		end
	end,
	'Maps Forwarding Service',
	true
)

process.wait(uiProcess)
process.kill(forwardingProcess)
process.kill(rerenderAllProcess)

if (not wasModemOpen) then
	modem.close(shared.CHANNEL)
end
