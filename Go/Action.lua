Action = Class()

Action.RETRY = 'retry'
Action.IGNORE = 'ignore'
Action.ABORT = 'abort'

function Action.GetFactory(func)
	return function()
		return Action.new(
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

function Action:constructor(func)
	-- The function that this action object represents executing
	self.func = func

	self.times = 1
	self.optional = false
	self.type = 'abstract action'
	self.invert = false
	self.arguments = nil
	self.count = 1
end

function Action:innerFunction()
end

function Action:singleInvoke()
	return self.innerFunction(table.unpack(self.arguments)) or true
end

function Action:invoke(invoc)
end

function Action:call(invoc)
	return ActionResult.new(self, self.func(invoc.optional))
end

function Action:run(invoc)
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

function Action:mod(mod)
	if type(mod) == 'number' then
		self.count = mod
		return true
	end

	if type(mod) == 'string' then
		if mod == '?' then
			self.optional = true
			return true
		end

		if mod == '*' then
			self.count = -1
			return true
		end

		if mod == '~' then
			self.invert = true
			return true
		end
	end

	return false
end
