GatherSandSkill = Class(Skill)
GatherSandSkill.ClassName = 'GatherSandSkill'
GatherSandSkill.description = 'Gets sand'

function GatherSandSkill:canHandleTask(task)
	--TODO: 'minecraft:sand:0' == 'sand'
	return isType(task, GatherItemTask) and task.item == 'sand'
end

function GatherSandSkill:completeTask(task)
	--TODO: find sand
	print('pls give sand')
	read()
	return true
end
