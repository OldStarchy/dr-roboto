StoreItemTask = Class(Task)
StoreItemTask.ClassName = 'StoreItemTask'

function StoreItemTask:constructor(item, count)
	self.item = assertType(item, 'string')
	self.count = assertType(item, 'int')
end

function StoreItemTask:toString()
	return 'Store ' .. self.count .. ' ' .. self.item .. '(s)'
end

function StoreItemTask.FromArgs(args)
	local item = table.remove(args, 1)
	local count = table.remove(args, 1)
	return StoreItemTask(item, tonumber(count))
end

function StoreItemTask.Deserialize(obj)
	return StoreItemTask(obj.item, obj.count)
end
