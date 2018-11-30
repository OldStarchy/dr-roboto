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

		local result = skill:completeTask(task)
		if (result == true) then
			if (self._verbose) then
				print('Completed task ' .. tostring(task))
			end
		elseif (result == false) then
			error('Could not complete task')
		else
			for _, v in ipairs(result) do
				self._taskManager:addTask(v)
			end
			self._taskManager:addTask(task)
		end

		-- Long running tasks must call sleep regularly or they'll be killed
		sleep(0)

		loadfile('task')('list')
		read()

		task, skill = self:_getNextTaskAndSkill()
	end
end

function TaskRunner:_getNextTaskAndSkill()
	local tasks = self._taskManager:getTasks()

	if (#tasks == 0) then
		return nil
	end
	-- for i, task in ipairs(tasks) do
	local task = tasks[1]
	local skill = self._skillSet:getSkillForTask(task)

	if (skill ~= nil) then
		self._taskManager:removeTask(1)
		return task, skill
	end
	-- end

	return nil
end
