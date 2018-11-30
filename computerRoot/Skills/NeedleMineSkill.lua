NeedleMineSkill = Class(Skill)
NeedleMineSkill.ClassName = 'NeedleMineSkill'
NeedleMineSkill.description = 'Gets things from a needle mine'

NeedleMineSkill.Things = {
	cobblestone = true,
	iron_ore = true,
	coal = true
	--TODO: etc
}

function NeedleMineSkill:canHandleTask(task)
	--TODO: 'minecraft:sand:0' == 'sand'
	return isType(task, GatherItemTask) and NeedleMineSkill.Things[task.item]
end

function NeedleMineSkill:completeTask(task)
	--TODO: needlemine untill item count is enough
	print('pls give ' .. task.amount .. ' ' .. task.item .. '(s)')
	read()
	return true
end
