includeOnce 'lib/Graphics/Pixel'

local shared = {}

shared.CHANNEL = 10
shared.PACKET_REPORT_LOCATION = 'reportLocation'
shared.PACKET_FORWARD_LOCATION = 'forwardLocation'
shared.MAX_AGE = 60
local horizontalLineChar = Pixel.Compile(Pixel.MIDDLE).char

function shared.findWirelessModem()
	for _, name in ipairs(peripheral.getNames()) do
		local isModem = peripheral.hasType(name, 'modem')

		if (isModem) then
			local isWireless = peripheral.call(name, 'isWireless')

			if (isWireless) then
				return peripheral.wrap(name)
			end
		end
	end

	return nil
end

function shared.printHr()
	local width, _ = term.getSize()
	term.write(string.rep(horizontalLineChar, width))
end

function shared.printHeader(left, right)
	local width, _ = term.getSize()

	term.setCursorPos(1, 1)
	term.clearLine()

	term.write(left)

	term.setCursorPos(math.floor(width - #right + 1), 1)
	term.write(right)

	term.setCursorPos(1, 2)
	shared.printHr()
end

function shared.printLine(line, text)
	term.setCursorPos(1, line + 3)
	term.clearLine()
	term.write(text)
end

function shared.calculateAge(since)
	return math.floor((os.epoch('utc') - since) / 1000 + 0.5)
end

function shared.printReportedLocation(reportedLocation, offset, stagger)
	local id = reportedLocation.id
	local name = reportedLocation.name
	local age
	if (reportedLocation.age) then
		age = reportedLocation.age
	else
		age = shared.calculateAge(reportedLocation.time)
	end
	local location = reportedLocation.location

	local coordinateFormat = '%3d'

	local xText = string.format(coordinateFormat, location.x)
	local yText = string.format(coordinateFormat, location.y)
	local zText = string.format(coordinateFormat, location.z)

	local nameText = name
	local ageText = string.format('(%ds)', age)
	local locationText = ageText .. '  ' .. xText .. ', ' .. yText .. ', ' .. zText

	local width, _ = term.getSize()
	local gap = 1
	local spaceForLocationText = width - #locationText - gap

	if (not stagger) then
		if (spaceForLocationText < #nameText) then
			nameText = string.sub(nameText, 1, spaceForLocationText)
		else
			nameText = nameText .. string.rep(' ', spaceForLocationText - #nameText)
		end
	end

	local line = (stagger and (id * 2 - 1) or (id)) + offset

	term.setCursorPos(1, line)
	term.clearLine()
	if (not stagger) then
		local text = nameText .. string.rep(' ', gap) .. locationText

		term.write(text)
	else
		term.write(nameText)
		term.setCursorPos(1, line + 1)
		term.clearLine()
		term.write(string.format('%' .. width .. 's', locationText))
	end
end

function shared.idCounter()
	local id = 0
	return function()
		id = id + 1
		return id
	end
end

return shared
