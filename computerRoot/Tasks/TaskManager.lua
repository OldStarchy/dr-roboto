TaskManager = Class()
TaskManager.ClassName = 'TaskManager'

function TaskManager:constructor()
	--TODO: maybe queue isn't necassary here
	self._tasks = {}
end

function TaskManager:save(fname)
	local data = self._tasks

	fs.writeToFile(fname, data)
end

function TaskManager:count()
	return #self._tasks
end

function TaskManager:load(fname)
	local data = fs.readFromFile(fname)

	if (data) then
		self._tasks = {}
		for _, v in ipairs(data) do
			table.insert(self._tasks, v)
		end
	end
end

function TaskManager:addTask(task, index)
	assertType(task, Task)

	if (isType(index, 'number')) then
		table.insert(self._tasks, index, task)
	else
		table.insert(self._tasks, task)
	end
end

function TaskManager:getTasks()
	return cloneTable(self._tasks, 2)
end

function TaskManager:getTask(index)
	return self._tasks[index]
end

function TaskManager:removeTask(index)
	table.remove(self._tasks, index)
end
