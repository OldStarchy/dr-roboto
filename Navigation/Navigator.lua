local Nav = Class()

function Nav:constructor(turtle)
	local this = self

	self.autoDig = true
	self.autoAttack = false

	self.turtle = turtle
	self.oldTurtle = {}

	local overrideFunctionsList = {
		'forward',
		'back',
		'up',
		'down',
		'turnLeft',
		'turnRight'
	}

	for _, func in ipairs(overrideFunctionsList) do
		self.oldTurtle[func] = self.turtle[func]
		self.turtle[func] = function(...)
			return this[func](this, unpack({...}))
		end
	end

	local newFunctionsList = {
		'setAutoDig',
		'actuallyForward'
	}

	for _, func in ipairs(newFunctionsList) do
		self.turtle[func] = function(...)
			return this[func](this, unpack({...}))
		end
	end
end

Nav.UNKNOWNJ_FAILURE = 0

function Nav:move(direction, distance)
	distance = type(distance) == 'number' and distance or 1

	if (distance == 0) then
		return true
	end

	if (turtle.getFuelLevel() == 0) then
		return false, 4, 'There is a lack of fuel in the way'
	end

	local move, detect, dig, attack

	if (direction == 'forward') then
		move = self.oldTurtle.forward
		detect = self.turtle.detect
		dig = self.turtle.dig
		attack = self.turtle.attack
	elseif (direction == 'up') then
		move = self.oldTurtle.up
		detect = self.turtle.detectUp
		dig = self.turtle.digUp
		attack = self.turtle.attackUp
	elseif (direction == 'down') then
		move = self.oldTurtle.down
		detect = self.turtle.detectDown
		dig = self.turtle.digDown
		attack = self.turtle.attackDown
	end

	for i = 1, distance do
		if (not move()) then
			if (detect()) then
				if (self.autoDig) then
					while (detect()) do
						--TODO: autodig whitelist
						if (not dig()) then
							--bedrock
							return false, 3, 'There is a bedrock in the way'
						end
					end
				else
					return false, 1, 'There is a block in the way'
				end
			end
		else
			return true
		end

		while (not move()) do
			if (self.autoAttack) then
				while (attack()) do
				end
			else
				return false, 2, 'There is a mob in the way'
			end
		end
	end

	return true
end

function Nav:forward(distance)
	return self:move('forward', distance)
end
function Nav:up(distance)
	return self:move('up', distance)
end
function Nav:down(distance)
	return self:move('down', distance)
end
function Nav:back(distance)
	distance = ((type(distance) == 'number') and distance) or 1

	for i = 1, distance do
		if (not self.oldTurtle.back()) then
			return false, 0, "Couldn't move back and I don't know why"
		end
	end

	return true
end

function Nav:turnLeft(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self.oldTurtle.turnLeft()
	end

	return true
end

function Nav:turnRight(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self.oldTurtle.turnRight()
	end

	return true
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
