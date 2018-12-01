test(
	'Task Manager',
	{
		['List Tasks'] = function(t)
			taskManager = TaskManager()
			local tasks = taskManager:getTasks()
		end,
		['Glass Panes'] = function(t)
			taskManager = TaskManager()
			local task = GatherItemTask('glass_pane', 1)
			taskManager:addTask(task)

			local skillSet = SkillSet.GetDefaultSkillSet()

			local runner = TaskRunner(skillSet, taskManager, true)

			runner:run()
		end
	}
)
