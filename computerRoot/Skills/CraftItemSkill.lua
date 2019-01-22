CraftItemSkill = Class(Skill)
CraftItemSkill.ClassName = 'CraftItemSkill'
CraftItemSkill.description = 'Gets sand'

function CraftItemSkill:canHandleTask(task)
	--TODO: 'minecraft:sand:0' == 'sand'
	if (not isType(task, GatherItemTask)) then
		return false
	end

	local recipes = RecipeBook.Instance:findCraftingRecipesBySelector(task.item)

	return recipes ~= nil and #recipes ~= 0
end

function CraftItemSkill:getRequirements(task)
	local requirements = {}

	local recipe = RecipeBook.Instance:findBestCraftingRecipeBySelector(task.item)
	if recipe == nil then
		error('no recipes found for ' .. task.item)
	end

	for item, count in pairs(recipe.items) do
		local haveCount = Inv:countItem(item)
		local itemsNeeded = count - haveCount

		if (haveCount < count) then
			table.insert(requirements, GatherItemTask(item, itemsNeeded))
		end
	end

	return requirements
end

function CraftItemSkill:completeTask(task)
	return Crafting.craft(task.item, task.amount)
end
