Skill = Class()
Skill.ClassName = 'Skill'

Skill.priority = 0

-- return whether this task can fulfill the task requested.
function Skill:canHandleTask(task)
	return false
end

-- this code should execute the work expected from the skill
-- an error may be returned.
function Skill:completeTask(task)
	error('completTask not implemented for ' .. tostring(self), 2)
end

-- A table of tasks that need to be completed before this one can be ran.
function Skill:getRequirements(task)
	return {}
end

includeAll './Skill'
