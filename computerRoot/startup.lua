loadfile('roboto.lua', _ENV)()

local robotoIsLoaded = os.version and os.version():sub(1, 10) == 'Dr. Roboto'
if (not robotoIsLoaded) then
	return
end

includeOnce 'lib/Data/StateSaver'

local function loadAndBind(file, class, event, ...)
	local obj = Class.LoadOrNew(file, class, ...)
	StateSaver.BindToFile(obj, file, event)
	return obj
end

if (turtle) then
	includeOnce 'lib/Turtle/MoveManager'
	includeOnce 'lib/Turtle/Navigator'
	includeOnce 'lib/Turtle/Crafter'

	mov = loadAndBind('data/mov.tbl', MoveManager, 'turtle_moved', turtle)
	nav = Navigator(mov)
	Crafting = Crafter(turtle)
end

-- Map.Instance = Map()

-- TagManager.Instance = loadAndBind('data/tagmanager.tbl', TagManager, nil, Map.Instance)
-- BlockManager.Instance = loadAndBind('data/blockmanager.tbl', BlockManager, nil, Map.Instance)

-- log:info(#Skill.ChildTypes .. ' skills')

local singletons = {}
-- ItemInfo,
-- TaskManager

if (turtle) then
	table.insert(singletons, RecipeBook)
end

for _, v in ipairs(singletons) do
	log:info('Loading ' .. v.ClassName)
	v.Instance = loadAndBind('data/' .. string.lower(v.ClassName) .. '.tbl', v)
end
