Skill = Class()
Skill.ClassName = 'Skill'

Skill.priority = 0

function Skill:canHandleTask(task)
	return false
end

function Skill:completeTask(task)
	error('completTask not implemented for ' .. tostring(self), 2)
end
