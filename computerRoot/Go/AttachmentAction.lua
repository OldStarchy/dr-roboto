AttachmentAction = Class(Action)
AttachmentAction.ClassName = 'AttachmentAction'
function AttachmentAction.GetFactory(func)
	return function()
		return AttachmentAction(func)
	end
end
function AttachmentAction:constructor(itemFunc)
	Action.constructor(self)
	self.itemFunc = itemFunc
end
function AttachmentAction:call(invoc)
	return ActionResult(self, self.itemFunc())
end
