AttachmentAction = Class(Action)
function AttachmentAction.GetFactory(func)
	return function()
		return AttachmentAction.new(func)
	end
end
function AttachmentAction:constructor(itemFunc)
	Action.constructor(self)
	self.itemFunc = itemFunc
end
function AttachmentAction:call(invoc)
	return ActionResult.new(self, self.itemFunc())
end
