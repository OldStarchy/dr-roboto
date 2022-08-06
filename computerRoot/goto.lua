setfenv(1, _G)

includeOnce 'lib/Data/Position'
includeOnce 'lib/Data/StateSaver'
includeOnce 'lib/Cartography/Map'
includeOnce 'lib/Navigation/PathFinder'

local args = {...}

if (#args == 0) then
	print('goto x y z')
	print('goto x z')
	print('goto y')
	--print('goto namedLocation')
	return
end

local x = tonumber(args[1])
local y = tonumber(args[2])
local z = tonumber(args[3])


local map = Class.LoadOrNew('data/map.tbl', Map)
StateSaver.BindToFile(map, 'data/map.tbl')
local pathFinder = PathFinder(map)

local target = Position(x, y, z)

local function updateMap()
	local currPos = mov:getPosition()

	local blockAbove = turtle.inspectUp()
	local posAbove = currPos:up()

	local blockBelow = turtle.inspectDown()
	local posBelow = currPos:down()

	local block = turtle.inspect()
	local pos = currPos:forward()

	if (blockAbove ~= false) then
		print('marked block at ' .. tostring(posAbove) .. ' (above) as protected')
		map:setProtected(posAbove, true)
	end

	if (blockBelow ~= false) then
		print('marked block at ' .. tostring(posBelow) .. ' (below) as protected')
		map:setProtected(posBelow, true)
	end

	if (block ~= false) then
		print('marked block at ' .. tostring(pos) .. ' as protected')
		map:setProtected(pos, true)
	end

	map:setProtected(currPos, false)
end

local function move()
	local retry = true

	while (retry) do
		retry = false
		local position = nav:getPosition()

		local positions, fullPath = pathFinder:findPath(position, target, nil, true)

		if (positions == nil) then
			print('No path found')
			return
		end

		if (not fullPath) then
			retry = true
		end

		for _, p in ipairs(positions) do
			local moved, err, message = nav:goTo(p)

			updateMap()
			if (not moved) then
				if (err == MoveManager.HIT_BLOCK) then
					retry = true
				else
					print(message)
					return
				end
				break
			end
		end
	end
end

move()
