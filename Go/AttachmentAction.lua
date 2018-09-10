AttachmentAction = Class(Action)
function AttachmentAction.GetFactory(func)
	return function()
		return AttachmentAction.new(func)
	end
end
function AttachmentAction:constructor(itemFunc)
	self.itemFunc = itemFunc
end
function AttachmentAction:call(self, invoc)
	return ActionResult.new(self, self.itemFunc())
end
