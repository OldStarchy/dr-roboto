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
local target = Position(x, y, z)

nav:pathTo(target, true)
