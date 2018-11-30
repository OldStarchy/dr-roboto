Task = Class()
Task.ClassName = 'Task'

function Task:toString()
	return 'Task{' .. self.ClassName .. '}'
end

-- TODO:
-- function Task:finish(results)
-- 	self.hasFinished = true
-- 	self.results = results
-- end

GenericTask = Class(Task)

function GenericTask:constructor(name)
	Task.constructor(self)
	self.name = name
end

function Task:toString()
	return 'Task{' .. self.ClassName .. '} "' .. self.name .. '"'
end

function GenericTask.fromArgs(args)
	return GenericTask(table.remove(args, 1))
end
