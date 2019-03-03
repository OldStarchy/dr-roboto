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
		--TODO: move to skillset tests
		--[[
		['Find correct skill for task'] = function(t)
			RecipeBook.Instance = RecipeBook()

			local taskManager = TaskManager()
			local task = GatherItemTask('glass_pane', 1)
			taskManager:addTask(task)

			local skillSet = SkillSet.GetDefaultSkillSet()

			local runner = TaskRunner(skillSet, taskManager, true)

			runner:run()
		end,
		['test smelt item skill tree'] = function(t)
			RecipeBook.Instance = RecipeBook()

			local taskManager = TaskManager()
			local task = GatherItemTask('stone', 1)
			taskManager:addTask(task)

			local skillSet = SkillSet()
			skillSet:addSkill(GatherSandSkill())
			skillSet:addSkill(CraftItemSkill())
			skillSet:addSkill(NeedleMineSkill())
			skillSet:addSkill(SetupFurnaceSkill())
			skillSet:addSkill(SmeltItemSkill())

			local runner = TaskRunner(skillSet, taskManager, true)

			runner:run()
		end
		]]
	}
)
