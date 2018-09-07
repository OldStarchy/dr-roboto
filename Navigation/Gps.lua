local Gps = {}

function Gps.getPosition()
	--Turtle api to get position

	-- Unknown direction
	return Position.new(x, y, z, nil)
end

return Gps
