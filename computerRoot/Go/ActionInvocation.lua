ActionInvocation = Class()
ActionInvocation.ClassName = 'ActionInvocation'

function ActionInvocation:constructor(optional, previousResult)
	self.optional = optional
	self.previousResult = previousResult or ActionResult()
end
