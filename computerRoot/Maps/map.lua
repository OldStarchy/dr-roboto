includeOnce 'lib/Graphics/Pixel'
includeOnce 'lib/Graphics/Surface'
includeOnce 'lib/Graphics/Canvas'

local shared = require('shared')

local run = true
local modem = shared.findWirelessModem()

local width, height = term.getSize()
local headerSize = 2
local footerSize = 4

local nextClientId = shared.idCounter()
local reportedLocations = {}

local listingSurface = Surface(width, footerSize)
local mapSurface = Surface(width, height - headerSize - footerSize - 1)

local function handlePacket(packet)
	if (packet.type == shared.PACKET_FORWARD_LOCATION) then
		if (reportedLocations[packet.id] == nil) then
			reportedLocations[packet.id] = {
				id = packet.id
			}
		end

		reportedLocations[packet.id].name = packet.name
		reportedLocations[packet.id].location = packet.location
		reportedLocations[packet.id].age = packet.age

		local oldTerm = term.current()
		term.redirect(listingSurface:asTerm())
		shared.printReportedLocation(reportedLocations[packet.id], 0, false)
		term.redirect(oldTerm)
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

local run = true
local parentTerm = term.current()

term.clear()
shared.printHeader('Maps', 'press "q" to quit')
mapSurface:startMirroring(parentTerm, 1, headerSize + 1)
listingSurface:startMirroring(parentTerm, 1, height - footerSize + 1)
term.setCursorPos(1, height - footerSize)
shared.printHr()

local viewCenter = {x = 0, z = 0}
local viewZoom = 0
local trailsEnabled = false
local maxTrail = nil
local trail = {}
local showEdgeMarkers = false
local showSelf = true

local surfaceRenderer =
	process.spawnProcess(
	function()
		local mapTerm = mapSurface:asTerm()
		local termWidth, _ = mapTerm.getSize()
		local canvas = Canvas(mapSurface:getSize())

		while (run) do
			local scale = math.pow(1.2, viewZoom)

			canvas:clear()
			canvas:save()

			if (showEdgeMarkers) then
				local left = 0
				local right = canvas.width - 0
				local top = 0
				local bottom = canvas.height - 0

				-- canvas:line(left, top, right, top, true)
				-- canvas:line(left, bottom, right, bottom, true)
				-- canvas:line(left, top, left, bottom, true)
				-- canvas:line(right, top, right, bottom, true)

				-- Half way markers
				local centerX = canvas.width / 2
				local centerY = canvas.height / 2

				canvas:line(left, centerY, left + 3, centerY, true)
				canvas:line(right, centerY, right - 2, centerY, true)
				canvas:line(centerX, top, centerX, top + 3, true)
				canvas:line(centerX, bottom, centerX, bottom - 2, true)

				-- Quater markers
				local quaterX = canvas.width / 4
				local quaterY = canvas.height / 4

				canvas:line(left, quaterY, left + 2, quaterY, true)
				canvas:line(right, quaterY, right - 1, quaterY, true)
				canvas:line(left, quaterY * 3, left + 2, quaterY * 3, true)
				canvas:line(right, quaterY * 3, right - 1, quaterY * 3, true)

				canvas:line(quaterX, top, quaterX, top + 2, true)
				canvas:line(quaterX, bottom, quaterX, bottom - 1, true)
				canvas:line(quaterX * 3, top, quaterX * 3, top + 2, true)
				canvas:line(quaterX * 3, bottom, quaterX * 3, bottom - 1, true)
			end

			canvas:translate(canvas.width / 2, canvas.height / 2)

			if (showSelf) then
				canvas:set(0, 0, true)
			end

			canvas:scale(scale, scale)
			canvas:translate(-viewCenter.x, -viewCenter.z)

			for _, location in pairs(reportedLocations) do
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
			canvas:render(mapTerm, 1, 1)

			sleep(0.2)
		end
	end,
	'Maps Surface Renderer',
	true
)

local captureLocationsProcess =
	process.spawnProcess(
	function()
		while (run) do
			local event, side, channel, replyChannel, message, distance = os.pullEventRaw()

			if (event == 'modem_message') then
				if (channel == shared.CHANNEL) then
					handlePacket(message)
				end
			end
		end
	end,
	'Maps Capture Locations',
	true
)

local updateMapLocationProcess =
	process.spawnProcess(
	function()
		while (run) do
			local x, y, z = gps.locate()
			if (x) then
				viewCenter.x = x
				viewCenter.z = z
			end
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
			sleep(0.2)
		end
	end,
	'Maps Update Map Location',
	true
)

local uiProcess =
	process.spawnProcess(
	function()
		while (run) do
			local event = {os.pullEventRaw()}

			if (event[1] == 'terminate') then
				run = false
				break
			elseif (event[1] == 'key') then
				local key = event[2]

				if (key == keys.q) then
					run = false
					break
				elseif (key == keys.m) then
					showSelf = not showSelf
				elseif (key == keys.b) then
					showEdgeMarkers = not showEdgeMarkers
				elseif (key == keys.numPadAdd) then
					viewZoom = viewZoom + 1
				elseif (key == keys.numPadSubtract) then
					viewZoom = viewZoom - 1
				elseif (key == keys.t) then
					trailsEnabled = not trailsEnabled
					if (not trailsEnabled) then
						table.insert(trail, {})
					end
				elseif (key == keys.r) then
					trail = {}
				end
			end
		end
	end,
	'Maps Server UI',
	false
)

local deleteOldLocationsProcess =
	process.spawnProcess(
	function()
		while (run) do
			for name, reportedLocation in pairs(reportedLocations) do
				if (reportedLocation.age > shared.MAX_AGE) then
					reportedLocations[name] = nil
				end
			end
			sleep(1)
		end
	end,
	'Maps Server Rerenderer',
	true
)

process.wait(uiProcess)
run = false
process.kill(captureLocationsProcess)
process.kill(updateMapLocationProcess)
process.kill(surfaceRenderer)
process.kill(deleteOldLocationsProcess)

if (not wasModemOpen) then
	modem.close(shared.CHANNEL)
end

term.clear()
term.setCursorPos(1, 1)
