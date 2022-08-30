-- Creates the global `mov`, `nav`, `inv`, and `Crafting` objects
-- Creates the singletons for `ItemInfo.Instance` and `TaskManager.Instance`

includeOnce 'lib/Data/StateSaver'

local function loadAndBind(file, class, event, ...)
	local obj = Class.LoadOrNew(file, class, ...)
	StateSaver.BindToFile(obj, file, event)
	return obj
end

if (turtle) then
	includeOnce 'lib/Inventory/InventoryManager'
	includeOnce 'lib/Turtle/MoveManager'
	includeOnce 'lib/Turtle/Navigator'
	includeOnce 'lib/Turtle/Crafter'

	mov = loadAndBind('data/mov.tbl', MoveManager, 'turtle_moved', turtle)
	nav = Navigator(mov)
	inv = InventoryManager(turtle)
	Crafting = Crafter(turtle)
end

-- Map.Instance = Map()

-- TagManager.Instance = loadAndBind('data/tagmanager.tbl', TagManager, nil, Map.Instance)
-- BlockManager.Instance = loadAndBind('data/blockmanager.tbl', BlockManager, nil, Map.Instance)

-- log:info(#Skill.ChildTypes .. ' skills')

includeOnce 'lib/Inventory/ItemInfo'
includeOnce 'lib/Tasks/TaskManager'
local singletons = {
	ItemInfo,
	TaskManager
}

if (turtle) then
	table.insert(singletons, RecipeBook)
end

for _, v in ipairs(singletons) do
	log:info('Loading ' .. v.ClassName)
	v.Instance = loadAndBind('data/' .. string.lower(v.ClassName) .. '.tbl', v)
end

if (fs.exists('.roboto-crashed')) then
	fs.delete('.roboto-crashed')
	return true
end
