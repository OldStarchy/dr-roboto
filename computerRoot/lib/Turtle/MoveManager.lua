includeOnce '../Data/Position'

MoveManager = Class()
MoveManager.ClassName = 'MoveManager'

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
	self._afterPositionChangedListeners = {}

	self.ev = EventManager()
	self:_attach()
end

function MoveManager.Deserialize(tbl)
	local obj = MoveManager(turtle, tbl.verbose)

	obj.autoDig = not (not tbl.autoDig)
	obj.autoAttack = not (not tbl.autoAttack)
	obj.autoFuel = not (not tbl.autoFuel)

	if (tbl.position) then
		obj:setPosition(tbl.position)
	end

	return obj
end

function MoveManager:serialize()
	local tbl = {}

	tbl.verbose = self._verbose
	tbl.autoDig = self.autoDig
	tbl.autoAttack = self.autoAttack
	tbl.autoFuel = self.autoFuel
	tbl.position = self._position

	return tbl
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
	assertType(position, Position)
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
	return cloneTable(self._position)
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
		local attacked = false
		while (not move()) do
			if (self._turtle.getFuelLevel() == 0) then
				return false, MoveManager.NO_FUEL, 'There is a lack of fuel in the way'
			end

			local dug = false
			if (detect()) then
				if (self.autoDig) then
					--TODO: autodig whitelist
					if (dig()) then
						dug = true
					else
						--bedrock
						return false, MoveManager.HIT_BEDROCK, 'There is a bedrock in the way'
					end
				else
					return false, MoveManager.HIT_BLOCK, 'There is a block in the way'
				end
			end

			if (not dug) then
				if (self.autoAttack) then
					if (attack()) then
						attacked = true
					else
						if (not attacked) then
							return false, MoveManager.UNKNOWN_FAILURE, "I can't move and I don't know why"
						else
							-- Mob may be dead but still falling over, wait for it to despawn
							sleep(0.5) -- 0.5 from testing
						end
						attacked = false
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
	direction = Position.WrapDirection(direction + 2) - 2

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
		error('Invalid argument passed to nav:face')
	end

	return self:turn(self._position:getDirectionOffset(direction))
end

function MoveManager:trackLocation(filename)
	self._autoSaveFile = filename

	if (fs.exists(filename)) then
		self._position = Position(fs.readTableFromFile(filename))
		self:_afterPositionChanged()
	end
end

function MoveManager:locate()
	local position1 = Position(gps.locate())
	local move = {self:forward()}

	if (not move[1]) then
		return unpack(move)
	end

	local position2 = Position(gps.locate())

	local offset = position2:sub(position1)
	local direction = offset:getCardinalDirection()

	self:setPosition(
		Position(position2.x, position2.y, position2.z, direction)
	)

	return true
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
		local offset = Position.Offsets[self._position.direction]
		self._position:add(offset)
		self:_afterPositionChanged()
	end

	return unpack(result)
end

function MoveManager:_back()
	local result = {self._oldTurtle.back()}
	if (result[1]) then
		local offset = Position.Offsets[self._position.direction]
		self._position:sub(offset)
		self:_afterPositionChanged()
	end

	return unpack(result)
end

function MoveManager:_up()
	local result = {self._oldTurtle.up()}

	if (result[1]) then
		self._position:add({y = 1})
		self:_afterPositionChanged()
	end

	return unpack(result)
end

function MoveManager:_down()
	local result = {self._oldTurtle.down()}

	if (result[1]) then
		self._position:add({y = -1})
		self:_afterPositionChanged()
	end

	return unpack(result)
end

function MoveManager:_turnRight()
	local result = {self._oldTurtle.turnRight()}

	self._position:rotate(-1)
	self:_afterPositionChanged()

	return unpack(result)
end

function MoveManager:_turnLeft()
	local result = {self._oldTurtle.turnLeft()}

	self._position:rotate(1)
	self:_afterPositionChanged()

	return unpack(result)
end

function MoveManager:_afterPositionChanged()
	if (self._verbose) then
		print(self._position)
	end

	self.ev:trigger('turtle_moved', self:getX(), self:getY(), self:getZ(), self:getDirection())
	os.queueEvent('turtle_moved', self:getX(), self:getY(), self:getZ(), self:getDirection())

	if (self._autoSaveFile) then
		fs.writeTableToFile(self._autoSaveFile, self._position)
	end

	for func, _ in pairs(self._afterPositionChangedListeners) do
		func()
	end
end

--TODO: a better event handler system
function MoveManager:onPositionChanged(func)
	self._afterPositionChangedListeners[func] = true
end

function MoveManager:offPositionChanged(func)
	self._afterPositionChangedListeners[func] = nil
end
