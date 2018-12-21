CraftItemSkill = Class(Skill)
CraftItemSkill.ClassName = 'CraftItemSkill'
CraftItemSkill.description = 'Gets sand'

function CraftItemSkill:canHandleTask(task)
	--TODO: 'minecraft:sand:0' == 'sand'
	if (not isType(task, GatherItemTask)) then
		return false
	end

	local recipe = RecipeBook.Instance:findCraftingRecipeByName(task.item)

	return recipe ~= nil
end

function CraftItemSkill:getRequirements(task)
	local requirements = {}

	local recipe = RecipeBook.Instance:findCraftingRecipeByName(task.item)

	for item, count in pairs(recipe.items) do
		local haveCount = Inv:countItem(item)

		if (haveCount < count) then
			table.insert(requirements, GatherItemTask(item, count - haveCount))
		end
	end

	return requirements
end

function CraftItemSkill:completeTask(task)
	return Crafting.craft(task.item, task.amount)
end
