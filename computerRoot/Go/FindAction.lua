FindAction = Class(Action)
FindAction.ClassName = 'FindAction'
function FindAction.GetFactory(func)
	return function()
		return FindAction(func)
	end
end
function FindAction:constructor(findFunc)
	Action.constructor(self)
	self.findFunc = findFunc
	self.findstr = nil
	self.metadata = nil
end

function FindAction:call(invoc)
	local success, result
	success, result = self.findFunc()

	if not success then
		return ActionResult(self, false)
	end

	if not self.findstr then
		return ActionResult(self, true, result.name)
	end

	if not string.find(result.name, self.findstr, 1, true) then
		return ActionResult(self, false, result.name)
	end

	if not self.metadata then
		return ActionResult(self, true, result.name)
	end

	if result.metadata == self.metadata then
		return ActionResult(self, true)
	end

	return ActionResult(self, false, result.metadata)
end
function FindAction:mod(mod)
	if type(mod) == 'number' then
		self.metadata = mod
		return true
	end

	if type(mod) == 'table' then
		self.findstr = mod.str
		return true
	end

	return Action.mod(self, mod)
end
