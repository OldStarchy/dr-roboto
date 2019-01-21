SetupFurnaceSkill = Class(Skill)
SetupFurnaceSkill.ClassName = 'SetupFurnaceSkill'

function SetupFurnaceSkill:canHandleTask(task)
	return isType(task, SetupTask) and task.itemType == Furnace.ClassName
end

function SetupFurnaceSkill:getRequirements(task)
	-- alternatively it should look for a furnace in the inventory or in a known chest
	if (Inv:countItem(Furnace.ClassName) == 0) then
		return {GatherItemTask(Furnace.ClassName, 1)}
	end
	return {}
end
