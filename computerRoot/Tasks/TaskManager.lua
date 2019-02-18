TaskManager = Class()
TaskManager.ClassName = 'TaskManager'

function TaskManager:constructor()
	self._tasks = {}

	self.ev = EventManager()
end

function TaskManager:serialize()
	return cloneTable(self._tasks, 4)
end

function TaskManager:count()
	return #self._tasks
end

function TaskManager.Deserialize(obj)
	assertType(obj, 'table')

	local tm = TaskManager()
	for _, v in ipairs(obj) do
		tm:addTask(v)
	end
	return tm
end

function TaskManager:addTask(task, index)
	assertType(task, Task)

	if (isType(index, 'number')) then
		table.insert(self._tasks, index, task)
	else
		table.insert(self._tasks, task)
	end

	self.ev:trigger('state_changed')
end

function TaskManager:getTasks()
	--TODO: type-safe clone
	return self._tasks
end

function TaskManager:getTask(index)
	return self._tasks[index]
end

function TaskManager:removeTask(index)
	table.remove(self._tasks, index)

	self.ev:trigger('state_changed')
end
