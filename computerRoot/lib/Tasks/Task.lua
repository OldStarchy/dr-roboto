Task = Class()
Task.ClassName = 'Task'

function Task:toString()
	return 'Task{' .. self.ClassName .. '}'
end

function Task:serialize()
	local obj = {}

	for i, v in pairs(self) do
		obj[i] = v
	end

	return obj
end

function Task.Deserialize(obj)
	error('Deserialize is not defined for this task type, please write it', 2)
end

-- TODO:
-- function Task:finish(results)
-- 	self.hasFinished = true
-- 	self.results = results
-- end

includeAll 'Tasks/Task'
