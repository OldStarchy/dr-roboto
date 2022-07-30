RedstoneAction = Class(Action)
RedstoneAction.ClassName = 'RedstoneAction'

function RedstoneAction.GetFactory(side)
	return function()
		return RedstoneAction(side)
	end
end

function RedstoneAction:constructor(side)
	Action.constructor(self)

	self.side = side
	self.on = true
end

function RedstoneAction:call(invoc)
	redstone.setOutput(self.side, self.on)
	return ActionResult(self, true)
end

function RedstoneAction:mod(mod)
	if (FunctionAction.mod(self, mod)) then
		return true
	end

	if type(mod) == 'string' then
		if mod == '!' then
			self.on = false
			return true
		end
	end

	return false
end
