TaskRunner = Class()
TaskRunner.ClassName = 'TaskRunner'

function TaskRunner:constructor(skillSet, taskManager, verbose)
	self._skillSet = assertType(skillSet, SkillSet)
	self._taskManager = assertType(taskManager, TaskManager)
	self._verbose = assertType(coalesce(verbose, false), 'boolean')
end

function TaskRunner:run()
	while (self._taskManager:count() > 0) do
		local task = self._taskManager:getTask(1)
		local skill = self._skillSet:getSkillForTask(task)

		if (skill == nil) then
			--TODO: don't just error ig guess?
			error('No skills for task')
		end

		if (self._verbose) then
			print('Gathering requirements')
		end

		local requirements = skill:getRequirements(task)

		if (self._verbose) then
			if (requirements ~= nil and #requirements == 0) then
				print('None!')
			else
				for _, requirement in ipairs(requirements) do
					print(' ' .. tostring(requirement))
				end
			end
		end

		if (#requirements ~= 0) then
			for _, requirement in ipairs(requirements) do
				self._taskManager:addTask(requirement, 1)
			end
		else
			if (self._verbose) then
				print('Running task ' .. tostring(task))
			end

			local result = skill:completeTask(task)
			if (result) then
				if (self._verbose) then
					print('Completed task ' .. tostring(task))
				end
				self._taskManager:removeTask(1)
			else
				error('Could not complete task')
			end
		end

		-- Long running tasks must call sleep regularly or they'll be killed
		sleep(0)

		loadfile('task')('list')
		read()
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
