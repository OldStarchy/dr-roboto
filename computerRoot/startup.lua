shell.setPath('/tap/bin:' .. shell.path())
local drRobotoIsLoaded = os.version and os.version():sub(1, 10) == 'Dr. Roboto'

print('Roboto is ' .. (drRobotoIsLoaded and 'loaded' or 'not loaded'))

if (not drRobotoIsLoaded) then
	if (fs.exists('.roboto-crashed')) then
		print('Roboto has crashed. Delete the .roboto-crashed file to clear this message.')
		return
	end
	fs.open('.roboto-crashed', 'w').close()

	_G.shell = shell

	loadfile('roboto.lua', _ENV)()
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

fs.delete('.roboto-crashed')
