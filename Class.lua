function Class(parent)
	local class = {}

	function class.getType()
		return class
	end

	function class.constructor(...)
		if (parent and parent.constructor) then
			parent.constructor(...)
		end
	end

	local new = function(_, ...)
		-- First argument is always class
		local object =
			setmetatable(
			{},
			{
				__index = class
			}
		)

		if (class.constructor ~= nil) then
			class.constructor(object, ...)
		end

		return object
	end

	local classType = {
		__index = parent,
		__call = new
	}
	setmetatable(class, classType)
	return class
end
