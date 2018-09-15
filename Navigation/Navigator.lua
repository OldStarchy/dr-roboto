local Navigator = Class()

--[[
	A Location is an (x, y, z)
	A Position is a Location with a facing direction
]]

--[[
	A wrapper / extension to the movement functions defined for a turtle.
	Initialized as "Nav" at the bottom of this file.
]]
function Navigator:constructor(turtle)
	-- Public api stuff
	-- Should the movement functions dig blocks that are in the way?
	self.autoDig = false

	-- Should the movement functions attack mobs that are in the way?
	self.autoAttack = false

	-- Should fuel automatically be consumed from the inventory if required?
	-- TODO: autoFuel
	self.autoFuel = true


	-- Private stuff
	self._locationStack = {
		Position()
	}

	self._position = Position()
	self._turtle = turtle
	self._oldTurtle = {}

	self:_attach()
end

Navigator.UNKNOWN_FAILURE = 0
Navigator.HIT_BLOCK = 1
Navigator.HIT_MOB = 2
Navigator.HIT_BEDROCK = 3
Navigator.NO_FUEL = 4


-- Public

--Saves the current location
function Navigator:pushPosition()
	table.insert(self._locationStack, self._location)
end

--Returns to the most previously saved location
function Navigator:popPosition()
	if (#self._locationStack > 0) then
		local location = table.remove(self._locationStack, #self._locationStack)
		return self:goto(location), location
	end
	return false
end


-- Moves the turtle
-- direction can be 'up', 'down', 'forward', or 'back'
function Navigator:move(direction, distance)
	if (direction == 'back') then
		return self:back(distance)
	end

	distance = type(distance) == 'number' and distance or 1

	if (distance == 0) then
		return true
	end

	if (self._turtle.getFuelLevel() == 0) then
		return false, Navigator.NO_FUEL, 'There is a lack of fuel in the way'
	end

	local move, detect, dig, attack

	if (direction == 'forward') then
		move = function() return self:_forward() end
		detect = self._turtle.detect
		dig = self._turtle.dig
		attack = self._turtle.attack
	elseif (direction == 'up') then
		move = function() return self:_up() end
		detect = self._turtle.detectUp
		dig = self._turtle.digUp
		attack = self._turtle.attackUp
	elseif (direction == 'down') then
		move = function() return self:_down() end
		detect = self._turtle.detectDown
		dig = self._turtle.digDown
		attack = self._turtle.attackDown
	end

	for i = 1, distance do
		if (not move()) then
			if (detect()) then
				if (self.autoDig) then
					while (detect()) do
						--TODO: autodig whitelist
						if (not dig()) then
							--bedrock
							return false, Navigator.HIT_BEDROCK, 'There is a bedrock in the way'
						end
					end
				else
					return false, Navigator.HIT_BLOCK, 'There is a block in the way'
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
				return false, Navigator.HIT_MOB, 'There is a mob in the way'
			end
		end
	end

	return true
end

function Navigator:forward(distance)
	return self:move('forward', distance)
end
function Navigator:up(distance)
	return self:move('up', distance)
end
function Navigator:down(distance)
	return self:move('down', distance)
end
function Navigator:back(distance)
	distance = ((type(distance) == 'number') and distance) or 1

	for i = 1, distance do
		if (not self:_back()) then
			return false, 0, "Couldn't move back and I don't know why"
		end
	end

	return true
end

function Navigator:turn(direction)
	direction = Position.wrapDirection(direction + 2) - 2

	if (direction == 0) then
		return true
	elseif (direction > 0) then
		return self:turnLeft(direction)
	else
		return self:turnRight(-direction)
	end
end

function Navigator:turnLeft(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self:_turnLeft()
	end

	return true
end

function Navigator:turnRight(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self:_turnRight()
	end

	return true
end

function Navigator:setPosition(location)
	self._location = location
end

function Navigator:orientFromGps(gps)
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

	self:setPosition(newLocation)

	if (self:moveBack()) then
		result = location

		while (turns > 0) do
			self:turnLeft()
		end
	end
end


function Navigator:getX() return self._position.x end
function Navigator:getY() return self._position.y end
function Navigator:getZ() return self._position.z end
function Navigator:getDirection() return self._position.direction end

function Navigator:face( direction )
  if type(direction) ~= 'number' then
    error('Invalid argument passed to Nav:face')
  end

  return self:turn(self._position:getDirectionOffset(direction))
end

-- Go to absolute x coordinate
function Navigator:gotoX(x)
	local dir = self._position.direction
	local delta = x - self._position.x

	if (delta == 0) then
		return true
	end

	if (delta > 0) then
		self:face(Position.EAST)
			return self:forward(delta)
	else
		self:face(Position.WEST)
		return self:forward(-delta)
	end
end

function Navigator:gotoY(y)
	local delta = y - self._position.y

	if (delta == 0) then
		return true
	end

	if (delta > 0) then
			return self:up(delta)
	else
		return self:down(-delta)
	end
end

function Navigator:gotoZ(z)
	local dir = self._position.direction
	local delta = z - self._position.z

	if (delta == 0) then
		return true
	end

	if (delta > 0) then
		self:face(Position.SOUTH)
			return self:forward(delta)
	else
		self:face(Position.NORTH)
		return self:forward(-delta)
	end
end

--[[ usage:
goto(y)
goto(x, z)
goto(x, y, z) 
goto({x, y, z})
goto({x = x, y = y, z = z})
]]
function Navigator:goto(x, y, z)
	if type(z) == "nil" then
		if type(y) == "nil" then
			if type(x) == "nil" then
				return false
			else
				if type(x) == "table" then
					if #x < 3 then
						return
					else
						x, y, z = x.x or x[1], x.y or x[2], x.z or x[3]
					end
				else
					return self:gotoY(x)
				end
			end
		else
		--x and y but not z, so assume they meen x, z
		z = y
		y = self._position.y
		end
	end

	self:gotoX(x)
	self:gotoZ(z)
	self:gotoY(y)
	return x == self._position.x and y == self._position.y and z == self._position.z
end

-- PRIVATE

function Navigator:_attach()
	local this = self
	local overrideFunctionsList = {
		'forward',
		'back',
		'up',
		'down',
		'turnLeft',
		'turnRight'
	}

	for _, func in ipairs(overrideFunctionsList) do
		self._oldTurtle[func] = self._turtle[func]
		self._turtle[func] = function(...)
			return this[func](this, unpack({...}))
		end
	end

	local newFunctionsList = {
		'setAutoDig',
		'actuallyForward'
	}

	for _, func in ipairs(newFunctionsList) do
		self._turtle[func] = function(...)
			return this[func](this, unpack({...}))
		end
	end
end

function Navigator:_forward()
	local result = {self._oldTurtle.forward()}
	if (result[1]) then
		local offset = Position.offsets[self._position.direction];
		self._position:add(offset)
	end

	return unpack(result)
end

function Navigator:_back()
	local result = {self._oldTurtle.back()}
	if (result[1]) then
		local offset = Position.offsets[self._position.direction];
		self._position:sub(offset)
	end

	return unpack(result)
end

function Navigator:_up()
	local result = {self._oldTurtle.up()}

	if (result[1]) then
		self._position:add({y = 1})
	end

	return unpack(result)
end

function Navigator:_down()
	local result = {self._oldTurtle.down()}

	if (result[1]) then
		self._position:add({y = -1})
	end

	return unpack(result)
end

function Navigator:_turnRight()
	local result = {self._oldTurtle.turnRight()}

	self._position:rotate(-1)

	return unpack(result)
end

function Navigator:_turnLeft()
	local result = {self._oldTurtle.turnLeft()}

	self._position:rotate(1)

	return unpack(result)
end

function Navigation:_afterMove()
	print('Current position:')
	print('x', 'y', 'z', 'direction')
	print(
		self._position.x,
		self._position.y,
		self._position.z,
		Position.directionNames[self._position.direction]
	)
end

Nav = Navigator(turtle)
