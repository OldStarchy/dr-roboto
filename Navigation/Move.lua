Move = Class()

--[[
	A wrapper the movement functions defined for a turtle.

	Replaces the functions
		'forward',
		'back',
		'up',
		'down',
		'turnLeft',
		'turnRight'

	Keeps track of the current position by modifying coordinates after each successful move
]]
function Move:constructor(turtle)
	-- Public api stuff
	-- Should the movement functions dig blocks that are in the way?
	self.autoDig = false

	-- Should the movement functions attack mobs that are in the way?
	self.autoAttack = false

	-- Should fuel automatically be consumed from the inventory if required?
	-- TODO: autoFuel
	self.autoFuel = true

	-- Private stuff
	self._position = Position()
	self._turtle = turtle
	self._oldTurtle = {}

	self:_attach()
end

Move.UNKNOWN_FAILURE = 0
Move.HIT_BLOCK = 1
Move.HIT_MOB = 2
Move.HIT_BEDROCK = 3
Move.NO_FUEL = 4

-- Public

function Move:setPosition(position)
	assert(position.isType(Position))
	self._position = position
end

function Move:getX()
	return self._position.x
end
function Move:getY()
	return self._position.y
end
function Move:getZ()
	return self._position.z
end
function Move:getDirection()
	return self._position.direction
end

function Move:getPosition()
	return self._position
end

--[[
	Moves the turtle
	direction: 'up', 'down', 'forward', or 'back'
	distance: how many blocks to move

	returns true if movement was sucessful, or false, errCode, errText if move failed

	TODO: report back partial success when distance is > 1 and total movement is > 0
]]
function Move:move(direction, distance)
	if (direction == 'back') then
		return self:back(distance)
	end

	distance = type(distance) == 'number' and distance or 1

	if (distance == 0) then
		return true
	end

	local move, detect, dig, attack

	if (direction == 'forward') then
		move = function()
			return self:_forward()
		end
		detect = self._turtle.detect
		dig = self._turtle.dig
		attack = self._turtle.attack
	elseif (direction == 'up') then
		move = function()
			return self:_up()
		end
		detect = self._turtle.detectUp
		dig = self._turtle.digUp
		attack = self._turtle.attackUp
	elseif (direction == 'down') then
		move = function()
			return self:_down()
		end
		detect = self._turtle.detectDown
		dig = self._turtle.digDown
		attack = self._turtle.attackDown
	end

	for i = 1, distance do
		if (not move()) then
			if (self._turtle.getFuelLevel() == 0) then
				return false, Move.NO_FUEL, 'There is a lack of fuel in the way'
			end

			if (detect()) then
				if (self.autoDig) then
					while (detect()) do
						--TODO: autodig whitelist
						if (not dig()) then
							--bedrock
							return false, Move.HIT_BEDROCK, 'There is a bedrock in the way'
						end
					end
				else
					return false, Move.HIT_BLOCK, 'There is a block in the way'
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
				return false, Move.HIT_MOB, 'There is a mob in the way'
			end
		end
	end

	return true
end

function Move:forward(distance)
	return self:move('forward', distance)
end
function Move:up(distance)
	return self:move('up', distance)
end
function Move:down(distance)
	return self:move('down', distance)
end
function Move:back(distance)
	distance = ((type(distance) == 'number') and distance) or 1

	for i = 1, distance do
		if (not self:_back()) then
			return false, 0, "Couldn't move back and I don't know why"
		end
	end

	return true
end

function Move:turn(direction)
	direction = Position.wrapDirection(direction + 2) - 2

	if (direction == 0) then
		return true
	elseif (direction > 0) then
		return self:turnLeft(direction)
	else
		return self:turnRight(-direction)
	end
end

function Move:turnLeft(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self:_turnLeft()
	end

	return true
end

function Move:turnRight(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self:_turnRight()
	end

	return true
end

function Move:face(direction)
	if (type(direction) ~= 'number') then
		error('Invalid argument passed to Nav:face')
	end

	return self:turn(self._position:getDirectionOffset(direction))
end

-- PRIVATE

function Move:_attach()
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
end

function Move:_forward()
	local result = {self._oldTurtle.forward()}
	if (result[1]) then
		local offset = Position.offsets[self._position.direction]
		self._position:add(offset)
		self:_afterMove()
	end

	return unpack(result)
end

function Move:_back()
	local result = {self._oldTurtle.back()}
	if (result[1]) then
		local offset = Position.offsets[self._position.direction]
		self._position:sub(offset)
		self:_afterMove()
	end

	return unpack(result)
end

function Move:_up()
	local result = {self._oldTurtle.up()}

	if (result[1]) then
		self._position:add({y = 1})
		self:_afterMove()
	end

	return unpack(result)
end

function Move:_down()
	local result = {self._oldTurtle.down()}

	if (result[1]) then
		self._position:add({y = -1})
		self:_afterMove()
	end

	return unpack(result)
end

function Move:_turnRight()
	local result = {self._oldTurtle.turnRight()}

	self._position:rotate(-1)
	self:_afterMove()

	return unpack(result)
end

function Move:_turnLeft()
	local result = {self._oldTurtle.turnLeft()}

	self._position:rotate(1)
	self:_afterMove()

	return unpack(result)
end

function Move:_afterMove()
	print('Current position:')
	print('x', 'y', 'z', 'direction')
	print(self._position.x, self._position.y, self._position.z, Position.directionNames[self._position.direction])
end

Mov = Move(turtle)
