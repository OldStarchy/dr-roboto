TaskManager = Class()
TaskManager.ClassName = 'TaskManager'

function TaskManager:constructor()
	self._tasks = Queue()
end

function TaskManager:save(fname)
	local data = self._tasks:getItems()

	fs.writeToFile(fname, data)
end

function TaskManager:load(fname)
	local data = fs.readFromFile(fname)

	if (data) then
		self._tasks = Queue()
		for _, v in ipairs(data) do
			self._tasks:enqueue(v)
		end
	end
end

function TaskManager:addTask(task)
	assertType(task, 'Task')
	self._tasks:enqueue(task)
end

function TaskManager:getTasks()
	return self._tasks:getItems()
end
