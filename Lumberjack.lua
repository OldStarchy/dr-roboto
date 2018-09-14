local Lumberjack = {}
local log = Log('lumberjack')

local function collectLeaves()
	for i = 1, 4 do
		turtle.dig()
		turtle.turnRight()
	end
end

function Lumberjack.harvestTree()
	log:info('Harvesting Tree')
	turtle.dig()
	turtle.forward()
	local height = 0

	while (turtle.digUp()) do
		turtle.up()
		height = height + 1

		collectLeaves()
	end

	while (height > 0) do
		turtle.down()
		height = height - 1
	end

	turtle.back()
end

function Lumberjack.plantTree()
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
