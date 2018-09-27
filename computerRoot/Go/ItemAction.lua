ItemAction = Class(Action)
ItemAction.ClassName = 'ItemAction'
function ItemAction.GetFactory(func)
	return function()
		return ItemAction(func)
	end
end
function ItemAction:constructor(itemFunc)
	Action.constructor(self)
	self.itemFunc = itemFunc
	self.amount = nil
end

function ItemAction:call(invoc)
	local success
	if self.amount ~= nil then
		success = self.itemFunc(self.amount)
	else
		success = self.itemFunc()
	end

	return ActionResult(self, success)
end
function ItemAction:mod(mod)
	if type(mod) == 'number' then
		self.amount = mod
		return true
	end

	return Action.__index.mod(self, mod)
end
