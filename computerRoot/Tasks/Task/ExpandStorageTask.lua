ExpandStorageTask = Class(Task)
ExpandStorageTask.ClassName = 'ExpandStorageTask'

function ExpandStorageTask:constructor()
end

function ExpandStorageTask.Deserialize(obj)
	return ExpandStorageTask()
end
