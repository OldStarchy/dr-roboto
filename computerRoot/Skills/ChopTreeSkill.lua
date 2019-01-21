ChopTreeSkill = Class(Skill)
ChopTreeSkill.ClassName = 'ChopTreeSkill'
ChopTreeSkill.description = 'Chops down a tree'

function ChopTreeSkill:canHandleTask(task)
	return false --isType(task, ChopTreeTask)
end

function ChopTreeSkill:completeTask(task)
	Nav.goTo(task._location)
end

-- ChopTreeSkill = Class(Task)
-- ChopTreeSkill.ClassName = 'ChopTreeSkill'

-- function ChopTreeSkill.fromArgs(args)
-- 	return ChopTreeSkill(Position.fromArgs(args))
-- end

-- function ChopTreeSkill:constructor(location)
-- 	Task.constructor(self)

-- 	self._location = assertType(location, Position)
-- end

-- function ChopTreeSkill:toString()
-- 	return 'ChopTree{' .. tostring(self._location) .. '}'
-- end
