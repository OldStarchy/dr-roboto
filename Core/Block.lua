Block = Class()

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Block:constructor(name, location)
	assert(location:isType(Position), 'Location must be of type Position')

	self.location = location
	self.name = name

	self.interfaceLocation = Position(location.x, location.y, location.z, location.direction)
	self.interfaceLocation:sub(Position.offsets[location.direction])
end

function Block:toString()
	return 'Block: ' ..
		tostring(self.name) ..
			' at location: ' .. self.location:toString() .. ', interface location: ' .. self.interfaceLocation:toString()
end

-- TODO: make smarted
function Block:navigateTo()
	Nav:goTo(self.interfaceLocation.x, self.interfaceLocation.y, self.interfaceLocation.z)
	Mov:face(self.interfaceLocation.direction)
end

-- TODO: make smarted
function Block:place()
	self:navigateTo()
	Inv:select(name)
	turtle.place()
end
