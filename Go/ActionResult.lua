ActionResult = Class()

--[[
	Stores information about what happened when an action was run
]]
function ActionResult:constructor(action, success, data)
	self.action = action
	if (type(success) == 'boolean') then
		self.success = success
	else
		self.success = true
	end
	self.data = data
end
