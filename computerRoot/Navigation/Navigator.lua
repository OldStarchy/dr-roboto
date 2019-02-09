Navigator = Class()
Navigator.ClassName = 'Navigator'

--[[
	A Location is an (x, y, z)
	A Position is a Location with a facing direction
]]
--[[
	High level movement using coordinates
	Initialized as "Nav" at the bottom of this file.
]]
function Navigator:constructor(mov)
	assertType(mov, MoveManager, 'mov is not of type MoveManager')

	-- Private stuff
	self._locationStack = {
		mov:getPosition()
	}

	self._mov = mov
end

-- Public

--Saves the current location
function Navigator:pushPosition()
	table.insert(self._locationStack, self._mov.getPosition())
end

--Returns to the most previously saved location
function Navigator:popPosition()
	if (#self._locationStack > 0) then
		local location = table.remove(self._locationStack, #self._locationStack)
		return self:goTo(location), location
	end
	return false
end

function Navigator:getX()
	return self._mov:getX()
end
function Navigator:getY()
	return self._mov:getY()
end
function Navigator:getZ()
	return self._mov:getZ()
end
function Navigator:getDirection()
	return self._mov:getDirection()
end

function Navigator:getPosition()
	return self._mov:getPosition()
end

-- Go to absolute x coordinate
function Navigator:goToX(x)
	local dir = self:getDirection()
	local delta = x - self:getX()

	if (delta == 0) then
		return true
	end

	if (delta > 0) then
		self._mov:face(Position.EAST)
		return self._mov:forward(delta)
	else
		self._mov:face(Position.WEST)
		return self._mov:forward(-delta)
	end
end

function Navigator:goToY(y)
	local delta = y - self:getY()

	if (delta == 0) then
		return true
	end

	if (delta > 0) then
		return self._mov:up(delta)
	else
		return self._mov:down(-delta)
	end
end

function Navigator:goToZ(z)
	local dir = self:getDirection()
	local delta = z - self:getZ()

	if (delta == 0) then
		return true
	end

	if (delta > 0) then
		self._mov:face(Position.SOUTH)
		return self._mov:forward(delta)
	else
		self._mov:face(Position.NORTH)
		return self._mov:forward(-delta)
	end
end

--[[ usage:
goTo(y)
goTo(x, z)
goTo(x, y, z)
goTo({x, y, z})
goTo({x = x, y = y, z = z})
]]
function Navigator:goTo(x, y, z)
	if (type(z) == 'nil') then
		if (type(y) == 'nil') then
			if (type(x) == 'nil') then
				return false
			else
				if (type(x) == 'table') then
					x, y, z = x.x or x[1], x.y or x[2], x.z or x[3]
				else
					return self:goToY(x)
				end
			end
		else
			--x and y but not z, so assume they meen x, z
			z = y
			y = self:getY()
		end
	end

	if (x == nil or y == nil or z == nil) then
		error('invalid coordinates', 2)
	end

	self:goToY(y)
	self:goToX(x)
	self:goToZ(z)
	return x == self:getX() and y == self:getY() and z == self:getZ()
end

function Navigator:pathTo(x, y, z)
	if (type(z) == 'nil') then
		if (type(y) == 'nil') then
			if (type(x) == 'nil') then
				return false
			else
				if (type(x) == 'table') then
					x, y, z = x.x or x[1], x.y or x[2], x.z or x[3]
				else
					return self:goToY(x)
				end
			end
		else
			--x and y but not z, so assume they meen x, z
			z = y
			y = self:getY()
		end
	end

	if (x == nil or y == nil or z == nil) then
		error('invalid coordinates', 2)
	end
	print(self:getPosition())
	print(Position(x, y, z))
	local path = Map.Instance:findPath(self:getPosition(), Position(x, y, z))
	if (not path) then
		return false
	end
	for _, v in ipairs(path) do
		if (not self:goTo(v)) then
			return false
		end
	end

	return x == self:getX() and y == self:getY() and z == self:getZ()
end

Nav = Navigator(mov)
