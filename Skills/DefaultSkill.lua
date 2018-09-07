local DefaultSkill = Class(Skill) -- AKA "Ask for help Skill"

DefaultSkill.priority = 0

function DefaultSkill:peformTask(task)
	print("Help I don't know what i'm doing!")
	print('I need you to ' .. task)
	print("Press enter when you've done it! Thx")
	read()
	return true
end

function DefaultSkill:canHandleTask(task)
	return true
end

return DefaultSkill
