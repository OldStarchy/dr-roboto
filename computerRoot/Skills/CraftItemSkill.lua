CraftItemSkill = Class(Skill)
CraftItemSkill.ClassName = 'CraftItemSkill'
CraftItemSkill.description = 'Gets sand'

function CraftItemSkill:canHandleTask(task)
	--TODO: 'minecraft:sand:0' == 'sand'
	if (not isType(task, GatherItemTask)) then
		return false
	end

	local recipies = book:findByName(task.name)

	if (#recipies == 0) then
		return false
	end

	return true
end

function CraftItemSkill:completeTask(task)
	local requirements = {}

	local recipies = standardRecipes:findByName(task.name)
	-- for _, recipe in ipairs(recipies) do
	local recipe = recipes[1]
	for item, count in pairs(recipe.items) do
		local haveCount = Inv:countItem(item)

		if (haveCount < count) then
			table.push(requirements, GatherItemTask(item, count - haveCount))
		end
	end
	-- end

	if (#requirements > 0) then
		return requirements
	end

	Crafting.craft(task.item, task.amount)

	return true
end
