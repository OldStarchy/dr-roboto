MoveAction = Class(FunctionAction)
MoveAction.ClassName = 'MoveAction'
function MoveAction.GetFactory(func)
	return function()
		return MoveAction(
			function(optional)
				local success, m = func()
				if not success and not optional then
					while not success do
						success, m = func()
						sleep(0)
					end
				end
				return success, m
			end
		)
	end
end
function MoveAction:constructor(func)
	FunctionAction.constructor(self, func)
	self.autoDigAtack = false
end

function MoveAction:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local i = 1
	local r

	while self.count == -1 or i <= self.count do
		local autoDig = mov.autoDig
		local autoAttack = mov.autoAttack

		if (optional) then
			mov.autoDig = false
		end
		if (self.autoDigAttack) then
			mov.autoDig = true
			mov.autoAttack = true
		end
		r = self:call(ActionInvocation(optional, invoc.previousResult))
		mov.autoDig = autoDig
		mov.autoAttack = autoAttack

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
function MoveAction:mod(mod)
	if (FunctionAction.mod(self, mod)) then
		return true
	end

	if type(mod) == 'string' then
		if mod == '!' then
			self.autoDigAttack = true
			return true
		end
	end

	return false
end
