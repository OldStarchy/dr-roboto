Sequence = Class(Action)
function Sequence.GetFactory(actions)
	return function()
		return Sequence.new(actions)
	end
end
function Sequence:constructor(actions)
	self.count = 1
	self.optional = false
	self.retry = false
	self.seq = actions
end

function Sequence:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local r = nil
	local i = 1

	while self.count == -1 or i <= self.count do
		r = invoc.previousResult

		for _, v in ipairs(self.seq) do
			r = v:run(ActionInvocation.new(self.retry or self.optional, r))
			success = r.success

			if not success then
				if self.retry then
					i = i - 1
					break
				elseif self.optional then
					return ActionResult.new(self, true ~= self.invert, r)
				elseif optional then
					return ActionResult.new(self, false ~= self.invert, r)
				else
					return ActionResult.new(self, false ~= self.invert, r)
				end
			end

			sleep(0)
		end

		i = i + 1
		sleep(0)
	end

	return ActionResult.new(self, true ~= self.invert, r)
end

function Sequence:mod(mod)
	if type(mod) == 'string' then
		if mod == '?' then
			if self.retry then
				inputError("Sequence can't be optional and retrying")
			end
			self.optional = true
			return true
		end

		if mod == '!' then
			if self.optional then
				inputError("Sequence can't be optional and retrying")
			end
			self.retry = true
			return true
		end
	end

	return Action.mod(self, mod)
end
