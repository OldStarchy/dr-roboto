Block = Class()
Block.ClassName = 'Block'

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Block:constructor(name, location)
	assertType(location, Position, 'Location must be of type Position', 2)

	self.location = location
	self.name = name

	self.interfaceLocation = Position(location.x, location.y, location.z, location.direction)
	self.interfaceLocation:sub(Position.Offsets[location.direction])
end

function Block:toString()
	return 'Block: ' ..
		tostring(self.name) ..
			' at location: ' .. self.location:toString() .. ', interface location: ' .. self.interfaceLocation:toString()
end

-- TODO: make smarted
function Block:navigateTo()
	nav:goTo(self.interfaceLocation.x, self.interfaceLocation.y, self.interfaceLocation.z)
	mov:face(self.interfaceLocation.direction)
end

-- TODO: make smarted
function Block:place()
	self:navigateTo()
	inv:select(name)
	turtle.place()
end
