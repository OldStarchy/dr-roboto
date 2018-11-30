GatherItemTask = Class(Task)

function GatherItemTask:constructor(item, amount)
	Task.constructor(self)

	self.item = item
	self.amount = amount
end

function GatherItemTask:toString()
	return 'Gather ' .. self.amount .. ' ' .. self.item .. '(s)'
end
function GatherItemTask.fromArgs(args)
	local item = table.remove(args, 1)
	local count = table.remove(args, 1)
	return GatherItemTask(item, tonumber(count))
end
