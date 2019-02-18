DefaultSkill = Class(Skill) -- AKA "Ask for help Skill"
DefaultSkill.ClassName = 'DefaultSkill'

DefaultSkill.priority = -100

function DefaultSkill:completeTask(task)
	print("Help I don't know what i'm doing!")
	print('I need you to ' .. tostring(task))
	print("Press enter when you've done it! Thx")
	read()
	return true
end

function DefaultSkill:canHandleTask(task)
	return true
end
