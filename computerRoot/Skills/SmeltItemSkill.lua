SmeltItemSkill = Class(Skill)
SmeltItemSkill.ClassName = 'SmeltItemSkill'

function SmeltItemSkill:canHandleTask(task)
	if task.getType() == 'GatherItemTask' then
		local recipe = RecipeBook:findCraftingRecipeByName(task.item.name)
		if not recipe then
			return false
		end
		if recipe.getType() == 'FurnaceRecipe' then
			return true
		end
	end
end

function SmeltItemSkill:completeTask()
end

function SmeltItemSkill:getRequirements(task)
	-- if there is a furnace within x blocks then use that otherwise, return a SetupTask for a furnace
	blockMap = BlockMap.GetDefaultBlockMap()

	local currentLocation = Mov:getPosition()
	neareastFurnace = blockMap:findNearest(Furnace.ClassName, currentLocation)

	if (neareastFurnace == nil) then
		return {SetupTask(Furnace.ClassName)}
	else
		if (neareastFurnace.location:distanceTo(currentLocation) > 100) then
			return {SetupTask(Furnace.ClassName)}
		end
	end

	return {}
end
