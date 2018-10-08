TaskRunner = Class()
TaskRunner.ClassName = 'TaskRunner'

function TaskRunner:constructor(skillSet, taskManager, verbose)
	self._skillSet = assertType(skillSet, SkillSet)
	self._taskManager = assertType(taskManager, TaskManager)
	self._verbose = assertType(coalesce(verbose, false), 'boolean')
end

function TaskRunner:run()
	local task, skill = self:_getNextTaskAndSkill()

	while (skill ~= nil) do
		if (self._verbose) then
			print('Running task ' .. tostring(task))
		end

		skill:completeTask(task)

		if (self._verbose) then
			print('Completed task ' .. tostring(task))
		end

		-- Long running tasks must call sleep regularly or they'll be killed
		sleep(0)

		task, skill = self:_getNextTaskAndSkill()
	end
end

function TaskRunner:_getNextTaskAndSkill()
	local tasks = self._taskManager:getTasks()

	for i, task in ipairs(tasks) do
		local skill = self._skillSet:getSkillForTask(task)

		if (skill ~= nil) then
			self._taskManager:removeTask(i)
			return task, skill
		end
	end

	return nil
end
