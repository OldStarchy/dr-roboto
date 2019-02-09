NeedleMinePlanner = Class()
NeedleMinePlanner.ClassName = 'NeedleMinePlanner'

function NeedleMinePlanner:constructor(offset)
	self.ev = EventManager()
	self._offset = assertType(coalesce(offset, Position(0, 0, 0)), Position)
	self._lastLocationX = nil
	self._lastLocationZ = nil
end

function NeedleMinePlanner.Deserialize(obj)
	local np = NeedleMinePlanner()
	np._offset = Position.Deserialize(obj.offset)
	np._lastLocationX = obj.x
	np._lastLocationZ = obj.z
	return np
end

function NeedleMinePlanner:serialize()
	return {
		x = self._lastLocationX,
		z = self._lastLocationZ,
		offset = self._offset:serialize()
	}
end

function NeedleMinePlanner:getNextLocation()
	local x, z = self:_getNextPotentialLocation(self._lastLocationX, self._lastLocationZ)

	--TODO: waiting on getBlocksInRegion API

	--[[
	local blocks = Map.Instance:getBlocksInRegion(Position(x, 0, z), Position(x, 64, z))

	while (#blocks > 0) do
		x, z = self:_getNextPotentialLocation(x, z)
		blocks = Map.Instance:getBlocksInRegion(Position(x, 0, z), Position(x, 64, z))
	end
	]]
	return self:_pushLocation(x, z)
end

--[[
	Selects locations in the '+' pattern from 5x5 'chunks'. 'Chunks' are selected in cross-diagonal order, starting from 0, 0 heading towards +x, +z
]]
function NeedleMinePlanner:_getNextPotentialLocation(ox, oz)
	if (ox == nil) then
		return 0, 0
	end

	local x, z

	if ((oz + 1) % 5 == 0) then
		if (ox == 0) then
			x = (oz + 1) / 5
			z = 0
		else
			x = ox - 1
			z = oz + 1
		end
	else
		x = ox
		z = oz + 1
	end

	return x, z
end

function NeedleMinePlanner:_pushLocation(x, z)
	self._lastLocationX = x
	self._lastLocationZ = z

	self.ev:trigger('last_location_updated', x, z)

	return Position(5 * x + ((2 * z) % 5), 0, z):add(self._offset)
end
