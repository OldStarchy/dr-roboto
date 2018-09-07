local GatherItemTask = Class(Task)

function GatherItemTask:constructor(item, amount)
	Task.constructor(self)

	self.item = item
	self.amount = amount
end

return GatherItemTask
