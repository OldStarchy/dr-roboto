Task = Class()
Task.ClassName = 'Task'

function Task:constructor(name)
	self._name = assertType(name, 'string')
end

function Task:toString()
	return 'Task{' .. self._name .. '}'
end

function Task:getName()
	return self._name
end

-- TODO:
-- function Task:finish(results)
-- 	self.hasFinished = true
-- 	self.results = results
-- end
