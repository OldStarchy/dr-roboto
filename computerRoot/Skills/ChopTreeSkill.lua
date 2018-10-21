ChopTreeSkill = Class(Skill)
ChopTreeSkill.ClassName = 'ChopTreeSkill'
ChopTreeSkill.description = 'Chops down a tree'

function ChopTreeSkill:canHandleTask(task)
	return isType(task, ChopTreeTask)
end

function ChopTreeSkill:completeTask(task)
	Nav.goTo(task._location)
end

ChopTreeTask = Class(Task)
ChopTreeTask.ClassName = 'ChopTreeTask'

function ChopTreeTask.fromArgs(args)
	return ChopTreeTask(Position.fromArgs(args))
end

function ChopTreeTask:constructor(location)
	Task.constructor(self)

	self._location = assertType(location, Position)
end

function ChopTreeTask:toString()
	return 'ChopTree{' .. tostring(self._location) .. '}'
end
