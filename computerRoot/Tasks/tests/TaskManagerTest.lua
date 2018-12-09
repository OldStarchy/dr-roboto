test(
	'Task Manager',
	{
		['List Tasks'] = function(t)
			local taskManager = TaskManager()
			local tasks = taskManager:getTasks()

			-- No tasks added
			t.assertTableEqual(tasks, {})

			local task = GatherItemTask('glass_pane', 1)
			taskManager:addTask(task)

			tasks = taskManager:getTasks()
			t.assertTableEqual(tasks, {task})
		end
		-- ,
		-- ['Find correct skill for task'] = function(t)
		-- 	local taskManager = TaskManager()
		-- 	local task = GatherItemTask('glass_pane', 1)
		-- 	taskManager:addTask(task)

		-- 	local skillSet = SkillSet()

		-- 	local runner = TaskRunner(skillSet, taskManager, true)

		-- 	runner:run()
		-- end
	}
)
