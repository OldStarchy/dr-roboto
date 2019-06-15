local Lumberjack = Class()
Lumberjack.ClassName = 'Lumberjack'

function Lumberjack:constructor()
	self.ev = EventManager()
end

function Lumberjack:_collectLeaves()
	for i = 1, 4 do
		turtle.dig()
		turtle.turnRight()
	end
end

function Lumberjack:harvestTree()
	turtle.dig()

	self.ev:trigger('before_move', 'forward')
	turtle.forward()
	local height = 0

	while (turtle.digUp()) do
		self.ev:trigger('before_move', 'up')
		turtle.up()
		height = height + 1

		self:_collectLeaves()
	end

	while (height > 0) do
		turtle.down()
		height = height - 1
	end

	self.ev:trigger('before_move', 'back')
	turtle.back()
end

function Lumberjack:plantTree()
	error('Lumberjack:plantTree not implemented')
	--TODO: select sapling
	return turtle.place()
end

local args = {...}
if (#args > 0) then
	if (Lumberjack[args[1]]) then
		Lumberjack[args[1]]()
	end
else
	return Lumberjack
end
