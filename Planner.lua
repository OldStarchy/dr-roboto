local Planner = Class()

function Planner:planSchedule(tasks, skillSet)
	local skills = skillSet:getSkills()

	local designations = {}
	local remainingTasks = {}

	for _, task in ipairs(tasks) do
		local designated = false

		for _, skill in ipairs(skills) do
			if (skill:canHandleTask(task)) then
				if (designations[skill] == nil) then
					designations[skill] = {}
				end

				table.insert(designations[skill], task)
				designated = true
				break
			end
		end

		if (not designated) then
			table.insert(remainingTasks, task)
		end
	end

	return designations, remainingTasks
end
