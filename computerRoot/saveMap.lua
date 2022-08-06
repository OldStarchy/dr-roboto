setfenv(1, _G)

includeOnce 'lib/Cartography/Map'

local args = {...}

if (#args == 0) then
	print('saveMap outputFilename')
	return
end

local inputFilename = 'data/map.tbl'
local outputFilename = args[1]


local map = Class.LoadOrNew(inputFilename, Map)

map:saveToVoxelsVox(outputFilename)
