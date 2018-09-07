local TreeFarmSkill = Class(Skill)

function TreeFarmSkill:performNextAction()
	if (logCount >= requiredLogCount) then
		return self:finishTask()
	else
		for _, v in ipairs(self.currentFarm) do
			--go to tree
			if (self:hasTreeGrown()) then
				Lumberjack.harvestTree()
				Lumberjack.plantTree()
			--move tree to end of queue for harvesting oldest first?
			end
		end
	end
end

function TreeFarmSkill:canHandleTask(task)
	if (task.type == GatherItemTask) then
		if (task.item.name == 'log') then
			return true
		end
	end

	return false
end

return TreeFarmSkill
