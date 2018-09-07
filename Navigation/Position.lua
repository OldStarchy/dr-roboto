local Position = Class()

function Position:constructor(x, y, z, direction)
	self.x = x
	self.y = y
	self.z = z
	self.direction = direction
end

return Position
