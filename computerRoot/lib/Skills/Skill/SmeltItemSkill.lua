SmeltItemSkill = Class(Skill)
SmeltItemSkill.ClassName = 'SmeltItemSkill'

function SmeltItemSkill:canHandleTask(task)
	if isType(task, GatherItemTask) then
		local recipe = RecipeBook.Instance:findFurnaceRecipeBySelector(task.item)

		if not recipe then
			return false
		end
		if isType(recipe, FurnaceRecipe) then
			return true
		end
	end
end

function SmeltItemSkill:completeTask()
end

function SmeltItemSkill:getRequirements(task)
	-- if there is a furnace within x blocks then use that otherwise, return a SetupTask for a furnace

	local currentLocation = mov:getPosition()
	local neareastFurnace = BlockManager.Instance:findNearest(Furnace.ClassName, currentLocation)

	if (neareastFurnace == nil) then
		return {SetupTask(Furnace.ClassName)}
	else
		if (neareastFurnace.location:distanceTo(currentLocation) > 100) then
			return {SetupTask(Furnace.ClassName)}
		end
	end

	return {}
end
