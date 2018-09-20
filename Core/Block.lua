Block = Class()

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Block:constructor(name, location)
	assert(location.isType(Position), 'Location must be of type Position')

	self.location = location
	self.name = name

	self.interfaceLocation = Position(location.x, location.y, location.z, location.direction)

	local approachDirection = location.direction
	if approachDirection == Position.NORTH then
		self.interfaceLocation:sub({z = 1})
	elseif approachDirection == Position.SOUTH then
		self.interfaceLocation:add({z = 1})
	elseif approachDirection == Position.EAST then
		self.interfaceLocation:add({x = 1})
	elseif approachDirection == Position.WEST then
		self.interfaceLocation:sub({x = 1})
	else
		error('direction ' .. approachDirection .. 'is not a valid direction')
	end
end

-- TODO: make smarted
function Block:navigateTo()
	Nav:moveTo(self.interfaceLocation.x, self.interfaceLocation.y, self.interfaceLocation.z)
	Mov:face(self.interfaceLocation.direction)
end

-- TODO: make smarted
function Block:place()
	self:navigateTo()
	Inv:select(name)
	turtle.place()
end
