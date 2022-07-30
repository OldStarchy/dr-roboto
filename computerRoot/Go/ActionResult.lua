---@class ActionResult
ActionResult = Class()
ActionResult.ClassName = 'ActionResult'

--[[
	Stores information about what happened when an action was run
]]
---@param action Action
---@param success boolean
---@param data any
function ActionResult:constructor(action, success, data)
	self.action = action
	if (type(success) == 'boolean') then
		self.success = success
	else
		self.success = true
	end
	self.data = data
end
