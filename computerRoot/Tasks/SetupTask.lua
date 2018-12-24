SetupTask = Class(Task)

function SetupTask:constructor(itemType)
	Task.constructor(self)

	self.itemType = itemType
end

function SetupTask:toString()
	return 'Setup ' .. self.itemType
end

function SetupTask.fromArgs(args)
	local itemType = table.remove(args, 1)
	return SetupTask(itemType)
end
