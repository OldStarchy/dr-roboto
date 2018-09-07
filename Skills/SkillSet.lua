local SkillSet = Class()

function SkillSet:constructor()
	self:addSkill(DefaultSkill.new())
end

function SkillSet:getSkills()
	--TODO: order skills by priority, highest first

	return self.skills
end

return SkillSet
