SkillSet = Class()
SkillSet.ClassName = 'SkillSet'

function SkillSet.GetDefaultSkillSet()
	local skillSet = SkillSet()

	for _, v in pairs(Skill.ChildTypes) do
		skillSet:addSkill(v())
	end

	return skillSet
end

function SkillSet:constructor()
	self._skills = {}

	self:addSkill(DefaultSkill())
end

function SkillSet:addSkill(skill)
	assertType(skill, Skill)

	table.insert(self._skills, skill)

	table.sort(
		self._skills,
		function(a, b)
			return a.priority > b.priority
		end
	)
end

function SkillSet:getSkillCount()
	return #self._skills
end

function SkillSet:getSkillForTask(task)
	assertType(task, Task)

	for _, skill in ipairs(self._skills) do
		if (skill:canHandleTask(task)) then
			return skill
		end
	end
end

function SkillSet:getSkills()
	local r = {}

	for _, skill in ipairs(self._skills) do
		table.insert(r, skill)
	end

	return r
end
