GatherItemTask = Class(Task)
GatherItemTask.ClassName = 'GatherItemTask'

function GatherItemTask:constructor(item, count)
	Task.constructor(self)

	self.item = assertType(item, 'string')
	self.count = assertType(count, 'int')
end

function GatherItemTask:toString()
	return 'Gather ' .. self.count .. ' ' .. self.item .. '(s)'
end

function GatherItemTask.FromArgs(args)
	local item = table.remove(args, 1)
	local count = table.remove(args, 1)
	return GatherItemTask(item, tonumber(count))
end

function GatherItemTask.Deserialize(obj)
	return GatherItemTask(obj.item, obj.count)
end
