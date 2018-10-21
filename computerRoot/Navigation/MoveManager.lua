MoveManager = Class()
MoveManager.ClassName = 'Move'

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
function MoveManager:constructor(turtle, verbose)
	assertType(turtle, 'table')

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
	self._autoPropsStack = {}
	self._autoSaveFile = nil

	self._verbose = assertType(coalesce(verbose, false), 'boolean')

	self:_attach()
end

MoveManager.UNKNOWN_FAILURE = 0
MoveManager.HIT_BLOCK = 1
MoveManager.HIT_MOB = 2
MoveManager.HIT_BEDROCK = 3
MoveManager.NO_FUEL = 4

-- Public

function MoveManager:push(autoDig, autoAttack, autoFuel)
	table.insert(
		self._autoPropsStack,
		{
			autoDig = self.autoDig,
			autoAttack = self.autoAttack,
			autoFuel = self.autoFuel
		}
	)

	if (type(autoDig) == 'boolean') then
		self.autoDig = autoDig
	end
	if (type(autoAttack) == 'boolean') then
		self.autoAttack = autoAttack
	end
	if (type(autoFuel) == 'boolean') then
		self.autoFuel = autoFuel
	end
end

function MoveManager:pop()
	if (#self._autoPropsStack > 0) then
		local props = table.remove(self._autoPropsStack)
		self.autoDig = props.autoDig
		self.autoAttack = props.autoAttack
		self.autoFuel = props.autoFuel
	else
		error('Too many calls to MoveManager:pop', 2)
	end
end

function MoveManager:setPosition(position)
	assert(position.isType(Position))
	self._position = position
end

function MoveManager:getX()
	return self._position.x
end
function MoveManager:getY()
	return self._position.y
end
function MoveManager:getZ()
	return self._position.z
end
function MoveManager:getDirection()
	return self._position.direction
end

function MoveManager:getPosition()
	return self._position
end

--[[
	Moves the turtle
	direction: 'up', 'down', 'forward', or 'back'
	distance: how many blocks to move

	returns true if movement was sucessful, or false, errCode, errText if move failed

	TODO: report back partial success when distance is > 1 and total movement is > 0
]]
function MoveManager:move(direction, distance)
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
				return false, MoveManager.NO_FUEL, 'There is a lack of fuel in the way'
			end

			if (detect()) then
				if (self.autoDig) then
					while (detect()) do
						--TODO: autodig whitelist
						if (not dig()) then
							--bedrock
							return false, MoveManager.HIT_BEDROCK, 'There is a bedrock in the way'
						end
					end
				else
					return false, MoveManager.HIT_BLOCK, 'There is a block in the way'
				end
			end

			while (not move()) do
				if (self.autoAttack) then
					while (attack()) do
					end
				else
					return false, MoveManager.HIT_MOB, 'There is a mob in the way'
				end
			end
		end
	end

	return true
end

function MoveManager:forward(distance)
	return self:move('forward', distance)
end
function MoveManager:up(distance)
	return self:move('up', distance)
end
function MoveManager:down(distance)
	return self:move('down', distance)
end
function MoveManager:back(distance)
	distance = ((type(distance) == 'number') and distance) or 1

	for i = 1, distance do
		if (not self:_back()) then
			return false, 0, "Couldn't move back and I don't know why"
		end
	end

	return true
end

function MoveManager:turn(direction)
	direction = Position.wrapDirection(direction + 2) - 2

	if (direction == 0) then
		return true
	elseif (direction > 0) then
		return self:turnLeft(direction)
	else
		return self:turnRight(-direction)
	end
end

function MoveManager:turnLeft(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self:_turnLeft()
	end

	return true
end

function MoveManager:turnRight(times)
	times = ((type(times) == 'number') and times) or 1

	for i = 1, times do
		self:_turnRight()
	end

	return true
end

function MoveManager:face(direction)
	if (type(direction) ~= 'number') then
		error('Invalid argument passed to Nav:face')
	end

	return self:turn(self._position:getDirectionOffset(direction))
end

function MoveManager:trackLocation(filename)
	self._autoSaveFile = filename

	if (fs.exists(filename)) then
		self._position = Position(fs.readTableFromFile(filename))
	end
end

-- PRIVATE

function MoveManager:_attach()
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

function MoveManager:_forward()
	local result = {self._oldTurtle.forward()}
	if (result[1]) then
		local offset = Position.offsets[self._position.direction]
		self._position:add(offset)
		self:_afterMove()
	end

	return unpack(result)
end

function MoveManager:_back()
	local result = {self._oldTurtle.back()}
	if (result[1]) then
		local offset = Position.offsets[self._position.direction]
		self._position:sub(offset)
		self:_afterMove()
	end

	return unpack(result)
end

function MoveManager:_up()
	local result = {self._oldTurtle.up()}

	if (result[1]) then
		self._position:add({y = 1})
		self:_afterMove()
	end

	return unpack(result)
end

function MoveManager:_down()
	local result = {self._oldTurtle.down()}

	if (result[1]) then
		self._position:add({y = -1})
		self:_afterMove()
	end

	return unpack(result)
end

function MoveManager:_turnRight()
	local result = {self._oldTurtle.turnRight()}

	self._position:rotate(-1)
	self:_afterMove()

	return unpack(result)
end

function MoveManager:_turnLeft()
	local result = {self._oldTurtle.turnLeft()}

	self._position:rotate(1)
	self:_afterMove()

	return unpack(result)
end

function MoveManager:_afterMove()
	if (self._verbose) then
		print(self._position)
	end

	if (self._autoSaveFile) then
		fs.writeTableToFile(self._autoSaveFile, self._position)
	end
end

Mov = MoveManager(turtle)
