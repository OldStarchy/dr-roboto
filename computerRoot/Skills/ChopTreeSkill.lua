ChopTreeSkill = Class(Skill)
ChopTreeSkill.ClassName = 'ChopTreeSkill'

function ChopTreeSkill:canHandleTask(task)
	return isType(task, ChopTreeTask)
end

function ChopTreeSkill:completeTask(task)
	Nav.goTo(task._location)
end

ChopTreeTask = Class(Task)
ChopTreeTask.ClassName = 'ChopTreeTask'

function ChopTreeTask:constructor(location)
	Task.constructor(self)

	self._location = assertType(location, Position)
end
