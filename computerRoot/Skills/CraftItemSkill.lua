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

	local recipes = RecipeBook.Instance:findCraftingRecipeByName(task.item)
	if recipes == nil or #recipes == 0 then
		error('no recipes found for ' .. task.item)
	end

	local bestRecipe = nil
	local bestRecipeCount = 1000000

	for k, recipe in ipairs(recipes) do
		for item, count in pairs(recipe.items) do
			local haveCount = Inv:countItem(item)
			local itemsNeeded = count - haveCount

			if (haveCount < count and itemsNeeded < bestRecipeCount) then
				bestRecipe = recipe
				bestRecipeCount = itemsNeeded
			end
		end
	end

	if (bestRecipe ~= nil) then
		table.insert(requirements, GatherItemTask(bestRecipe, itemsNeeded))
	end

	return requirements
end

function CraftItemSkill:completeTask(task)
	return Crafting.craft(task.item, task.amount)
end
