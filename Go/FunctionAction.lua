FunctionAction = Class(Action)

function FunctionAction.GetFactory(func)
	return function()
		return FunctionAction.new(
			function(optional)
				local success, m = func()
				if not success and not optional then
					while not success do
						success, m = func()
						sleep(0)
					end
					return success, m
				end
				return success, m
			end
		)
	end
end

function FunctionAction:constructor(func)
	Action.constructor(self)
	-- The function that this action object represents executing
	self.func = func
end

function FunctionAction:singleInvoke()
	return self.innerFunction(table.unpack(self.arguments)) or true
end

function FunctionAction:call(invoc)
	return ActionResult.new(self, self.func(invoc.optional))
end

function FunctionAction:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local i = 1
	local r

	while self.count == -1 or i <= self.count do
		r = self:call(ActionInvocation.new(optional, invoc.previousResult))
		success = r.success ~= self.invert

		if not success then
			if self.optional then
				return ActionResult.new(self, true, r.data)
			elseif optional then
				return ActionResult.new(self, false, r.data)
			else
				i = i - 1
			end
		end

		i = i + 1
	end

	return ActionResult.new(self, true ~= self.invert, r.data)
end
