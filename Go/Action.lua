Action = Class()

Action.RETRY = 'retry'
Action.IGNORE = 'ignore'
Action.ABORT = 'abort'

function Action.GetFactory()
	error('Do not use Action directly', 2)
end

function Action:constructor()
	self.times = 1
	self.optional = false
	self.type = 'abstract action'
	self.invert = false
	self.arguments = nil
	self.count = 1
	self.sourceMap = {
		start = nil,
		en = nil
	}
	self.owner = nil
end

function Action:innerFunction()
end

function Action:singleInvoke()
	return self.innerFunction(table.unpack(self.arguments)) or true
end

function Action:invoke(invoc)
end

function Action:call(invoc)
	error('Do not use Action directly', 4)
end

function Action:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local i = 1
	local r

	while self.count == -1 or i <= self.count do
		r = self:call(ActionInvocation(optional, invoc.previousResult))
		success = r.success ~= self.invert

		if not success then
			if self.optional then
				return ActionResult(self, true, r.data)
			elseif optional then
				return ActionResult(self, false, r.data)
			else
				i = i - 1
			end
		end

		i = i + 1
	end

	return ActionResult(self, true ~= self.invert, r.data)
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
