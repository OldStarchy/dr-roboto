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
	print('NeedleMineSkill:canHandleTask(task)')
	if isType(task, GatherItemTask) then
		for thing, accepted in pairs(NeedleMineSkill.Things) do
			print(thing)
			print(accepted)
			if accepted then
				local detail = ItemDetail.FromId(thing)
				print(detail)
				if detail:matches(task.item) then
					return true
				end
			end
		end
	end

	return false
end

function NeedleMineSkill:completeTask(task)
	--TODO: needlemine untill item count is enough
	print('pls give ' .. task.amount .. ' ' .. task.item .. '(s)')
	read()
	return true
end
