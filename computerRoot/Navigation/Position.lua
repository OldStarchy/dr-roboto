Position = Class()
Position.ClassName = 'Position'

Position.EAST = 0
Position.NORTH = 1
Position.WEST = 2
Position.SOUTH = 3

Position.DirectionNames = {
	[0] = 'EAST',
	[1] = 'NORTH',
	[2] = 'WEST',
	[3] = 'SOUTH'
}

Position.Offsets = {
	[Position.EAST] = {x = 1, z = 0},
	[Position.NORTH] = {x = 0, z = -1},
	[Position.WEST] = {x = -1, z = 0},
	[Position.SOUTH] = {x = 0, z = 1}
}

function Position.WrapDirection(direction)
	return (((direction % 4) + 4) % 4)
end

--CLI helper
function Position.FromArgs(args)
	if (#args == 0) then
		error('Missing args for position')
	end

	if (args[1] == 'here') then
		table.remove(args, 1)
		return Position(mov:getPosition())
	end

	local numericArgs = {}

	local lim = math.min(4, #args)
	for i = 1, lim do
		table.insert(numericArgs, tonumber(table.remove(args, 1)))
	end

	return Position(unpack(numericArgs))
end

function Position:serialize()
	return {
		x = self.x,
		y = self.y,
		z = self.z,
		direction = self.direction
	}
end

function Position.Deserialize(tbl)
	return Position(tbl.x, tbl.y, tbl.z, tbl.direction)
end

function Position:constructor(x, y, z, direction)
	if (type(x) == 'table') then
		Position.constructor(self, x.x, x.y, x.z, x.direction)
		return
	end
	self.x = assertParameter(x, 'x', 'nil', 'number') or 0
	self.y = assertParameter(y, 'y', 'nil', 'number') or 0
	self.z = assertParameter(z, 'z', 'nil', 'number') or 0
	self.direction = assertParameter(direction, 'direction', 'nil', 'number') or 0
end

function Position:rotate(direction)
	if (self.direction == nil) then
		return
	end
	self.direction = Position.WrapDirection(self.direction + direction)

	return self
end

function Position:add(deltas)
	if (type(deltas.x) == 'number') then
		self.x = self.x + deltas.x
	end
	if (type(deltas.y) == 'number') then
		self.y = self.y + deltas.y
	end
	if (type(deltas.z) == 'number') then
		self.z = self.z + deltas.z
	end

	if (type(deltas.direction) == 'number') then
		self:rotate(deltas.direction)
	end

	return self
end

function Position:sub(deltas)
	if (type(deltas.x) == 'number') then
		self.x = self.x - deltas.x
	end
	if (type(deltas.y) == 'number') then
		self.y = self.y - deltas.y
	end
	if (type(deltas.z) == 'number') then
		self.z = self.z - deltas.z
	end

	if (type(deltas.direction) == 'number') then
		self:rotate(-deltas.direction)
	end

	return self
end

function Position:getDirectionOffset(direction)
	if (self.direction == nil) then
		return 0
	end
	return Position.WrapDirection(direction - self.direction)
end

function Position:forward(count)
	count = assertType(coalesce(count, 1), 'int')
	local offset = Position.Offsets[self.direction]
	return Position(self.x + (offset.x * count), self.y, self.z + (offset.z * count), self.direction)
end

function Position:back(count)
	return self:forward(-count)
end

function Position:up(count)
	count = assertType(coalesce(count, 1), 'int')

	return Position(self.x, self.y + count, self.z, self.direction)
end

function Position:down(count)
	return self:up(-count)
end

function Position:left(count)
	count = assertType(coalesce(count, 1), 'int')
	return Position(self):rotate(count)
end

function Position:right(count)
	count = assertType(coalesce(count, 1), 'int')
	return Position(self):rotate(-count)
end

function Position:toString()
	return 'x: ' ..
		self.x .. ', y: ' .. self.y .. ', z: ' .. self.z .. ', f: ' .. Position.DirectionNames[self.direction]:sub(1, 1)
end

function Position:posEquals(other)
	assertParameter(other, 'other', Position)

	return self.x == other.x and self.y == other.y and self.z == other.z
end

function Position:isEqual(other)
	assertParameter(other, 'other', 'table')

	return self.x == other.x and self.y == other.y and self.z == other.z and self.direction == other.direction
end

function Position:distanceTo(other)
	assertParameter(other, 'other', Position)

	return math.abs(self.x - other.x) + math.abs(self.y - other.y) + math.abs(self.z - other.z)
end

function Position:posHash()
	return tostring(self.x) .. ',' .. tostring(self.y) .. ',' .. tostring(self.z)
end

function Position:hash()
	return tostring(self.x) .. ',' .. tostring(self.y) .. ',' .. tostring(self.z) .. ',' .. tostring(self.direction)
end
