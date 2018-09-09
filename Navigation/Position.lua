Position = Class()

Position.EAST = 0
Position.NORTH = 1
Position.WEST = 2
Position.SOUTN = 3

Position.offsets = {
	[Position.EAST] = {x = 1, z = 0},
	[Position.NORTH] = {x = 0, z = -1},
	[Position.WEST] = {x = -1, z = 0},
	[Position.SOUTN] = {x = 0, z = 1}
}

function Position.wrapDirection(direction)
	return (((direction % 4) + 4) % 4)
end

function Position:constructor(x, y, z, direction)
	self.x = ((type(x) == 'number') and x) or 0
	self.y = ((type(y) == 'number') and y) or 0
	self.z = ((type(z) == 'number') and z) or 0
	self.direction = ((type(direction) == 'number') and direction) or 0
end

function Position:rotate(direction)
	if (self.direction == nil) then
		return
	end
	self.direction = Position.wrapDirection(self.direction + direction)
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
		self:rotate(direction)
	end
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
		self:rotate(-direction)
	end
end

function Position:getDirectionOffset(direction)
	if (self.direction == nil) then
		return 0
	end
	return Position.wrapDirection(direction - self.direction)
end
