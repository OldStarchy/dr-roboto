local TreeFarmSkill = Class(Skill)

function TreeFarmSkill:plantTree() -- Requires saplings
end

function TreeFarmSkill:harvestTree()
end

function TreeFarmSkill:hasTreeGrown()
end

function TreeFarmSkill:decideNextAction()
	if (logCount >= requiredLogCount) then
		return self:finishTask()
	else
		-- go to each tree
		if (self:hasTreeGrown()) then
			self:harvestTree()
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
