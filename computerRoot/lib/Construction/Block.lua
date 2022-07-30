includeOnce '../Data/Position'

Block = Class()
Block.ClassName = 'Block'

--[[
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Block:constructor(location)
	assertType(location, Position, 'Location must be of type Position', 2)

	self.location = location

	self.interfaceLocation = Position(location.x, location.y, location.z, location.direction)
	self.interfaceLocation:sub(Position.Offsets[location.direction])
end

function Block:toString()
	return self.ClassName ..
		': ' .. ' at location: ' .. self.location:toString() .. ', interface location: ' .. self.interfaceLocation:toString()
end

-- TODO: move to Navigator
function Block:navigateTo()
	nav:goTo(self.interfaceLocation.x, self.interfaceLocation.y, self.interfaceLocation.z)
	mov:face(self.interfaceLocation.direction)
end

-- TODO: Move some block placer class
-- function Block:place()
-- 	self:navigateTo()
-- 	inv:select(name)
-- 	turtle.place()
-- end
