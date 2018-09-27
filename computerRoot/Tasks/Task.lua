local Task = Class()

function Task:finish(results)
	self.hasFinished = true
	self.results = results
end

return Task
