DanceTask = Class(Task)
DanceTask.ClassName = 'DanceTask'

function DanceTask:toString()
	return 'Dance'
end

function DanceTask.Deserialize()
	return DanceTask()
end

function DanceTask:serialize()
	return {}
end

function DanceTask.FromArgs(args)
	return DanceTask()
end
