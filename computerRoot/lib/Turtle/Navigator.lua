includeOnce '../Data/Position'
includeOnce '../Data/StateSaver'
includeOnce '../Cartography/Map'
includeOnce '../Navigation/PathFinder'
includeOnce './MoveManager'

Navigator = Class()
Navigator.ClassName = 'Navigator'

--[[
	A Location is an (x, y, z)
	A Position is a Location with a facing direction
]]
--[[
	High level movement using coordinates
	Initialized as "nav" at the bottom of this file.
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

	local dir = self:getDirection()
	local r

	if (dir == Position.NORTH or dir == Position.SOUTH) then
		r = {self:goToZ(z)}
		if (not r[1]) then
			return unpack(r)
		end

		r = {self:goToX(x)}
		if (not r[1]) then
			return unpack(r)
		end
	end

	if (dir == Position.EAST or dir == Position.WEST) then
		r = {self:goToX(x)}
		if (not r[1]) then
			return unpack(r)
		end

		r = {self:goToZ(z)}
		if (not r[1]) then
			return unpack(r)
		end
	end

	r = {self:goToY(y)}
	if (not r[1]) then
		return unpack(r)
	end

	return true
end

function Navigator:pathTo(target, verbose)
	assertParameter(target, 'target', Position)
	verbose = coalesce(assertParameter(verbose, 'verbose', 'boolean', 'nil'), false)

	local distance = target:distanceTo(self:getPosition())

	if (distance == 0) then
		return true
	end

	if (distance == 1) then
		return self:goTo(target)
	end

	local map = Class.LoadOrNew('data/map.tbl', Map)
	StateSaver.BindToFile(map, 'data/map.tbl')
	local pathFinder = PathFinder(map)

	local nav = self

	local function updateMap()
		local currPos = nav:getPosition()

		local blockAbove = turtle.inspectUp()
		local posAbove = currPos:up()

		local blockBelow = turtle.inspectDown()
		local posBelow = currPos:down()

		local block = turtle.inspect()
		local pos = currPos:forward()

		if (blockAbove ~= false) then
			if (verbose) then
				print('marked block at ' .. tostring(posAbove) .. ' (above) as protected')
			end
			map:setProtected(posAbove, true)
		end

		if (blockBelow ~= false) then
			if (verbose) then
				print('marked block at ' .. tostring(posBelow) .. ' (below) as protected')
			end
			map:setProtected(posBelow, true)
		end

		if (block ~= false) then
			if (verbose) then
				print('marked block at ' .. tostring(pos) .. ' as protected')
			end
			map:setProtected(pos, true)
		end

		map:setProtected(currPos, false)
	end

	local function move()
		local retry = true

		while (retry) do
			retry = false
			local position = nav:getPosition()

			local positions, fullPath = pathFinder:findPath(position, target, nil, true)

			if (positions == nil) then
				if (verbose) then
					print('No path found')
				end
				return
			end

			if (not fullPath) then
				retry = true
			end

			for _, p in ipairs(positions) do
				local moved, err, message = nav:goTo(p)

				updateMap()
				if (not moved) then
					if (err == MoveManager.HIT_BLOCK) then
						retry = true
					else
						if (verbose) then
							print(message)
						end

						return false, message
					end
					break
				end
			end
		end

		return true
	end

	return move()
end
