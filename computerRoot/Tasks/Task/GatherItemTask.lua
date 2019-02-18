GatherItemTask = Class(Task)
GatherItemTask.ClassName = 'GatherItemTask'

function GatherItemTask:constructor(item, count)
	Task.constructor(self)

	self.item = item
	self.count = count
end

function GatherItemTask:toString()
	return 'Gather ' .. self.count .. ' ' .. self.item .. '(s)'
end

function GatherItemTask.FromArgs(args)
	local item = table.remove(args, 1)
	local count = table.remove(args, 1)
	return GatherItemTask(item, tonumber(count))
end
