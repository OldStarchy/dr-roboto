UseFurnaceSkill = Class(Skill)
UseFurnaceSkill.ClassName = 'UseFurnaceSkill'

function UseFurnaceSkill:performNextAction()
end

function UseFurnaceSkill:canHandleTask(task)
	if task.getType() == 'GatherItemTask' then
		local recipe = RecipeBook:findByName(task.item.name)
		if not recipe then
			return false
		end
		if recipe.getType() == 'FurnaceRecipe' then
			return true
		end
	end
end
