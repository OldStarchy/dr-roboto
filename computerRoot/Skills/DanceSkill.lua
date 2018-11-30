DanceSkill = Class(Skill)
DanceSkill.ClassName = 'DanceSkill'

DanceSkill.priority = 0

function DanceSkill:completeTask(task)
	local go = include 'Go/_main'

	go:execute('a?r4fblbr2bbl2bra?', true)

	return true
end

function DanceSkill:canHandleTask(task)
	return isType(task, GenericTask) and task.name == 'dance'
end
