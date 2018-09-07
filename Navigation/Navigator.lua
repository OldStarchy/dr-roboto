local Nav = Class()

function Nav:constructor(turtle)
	self.turtle = turtle
end

function Nav:setLocation(location)
	self.location = location
end

function Nav:orientFromGps(gps)
	local location = gps.getLocation()

	if (location == false) then
		return false, 'GPS not available'
	end

	local turns = 0
	local couldMove = self:moveForward()

	while (not couldMove and turns < 4) do
		self:turnRight()
		couldMove = self:moveForward()
	end

	if (not couldMove) then
		--fail
		return false, 'Could not move'
	end

	local newLocation = gps.getLocation()

	if (newLocation == false) then
		if (self:moveBack()) then
			while (turns > 0) do
				self:turnLeft()
			end
		end

		-- TODO: come up with a good Skill Result object
		return false, "Coudln't get 2 GPS signals"
	end

	local dx = newLocation.x - location.x
	local dz = newLocation.z - location.z

	local direction = nil
	if (dx > 0) then
		direction = Position.EAST
	elseif (dx < 0) then
		direction = Position.WEST
	elseif (dz > 0) then
		direction = Position.SOUTN
	elseif (dz < 0) then
		direction = Position.NORTH
	else
		error('Unreachable code reached!')
	end

	newLocation:setDirection(direction)

	Nav:setPosition(newLocation)

	if (self:moveBack()) then
		result = location

		while (turns > 0) do
			self:turnLeft()
		end
	end
end

return Nav
