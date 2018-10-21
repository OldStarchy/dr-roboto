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
