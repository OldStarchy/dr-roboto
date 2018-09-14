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
		__index = function(class, key)
			if (key == 'new') then
				return function(...)
					print('WARING, use of .new() is deprecated and will be removed sometime soon')
					printStackTrace(1, 2)
					return new(nil, ...)
				end
			else
				return rawget(class, key) or parent and parent[key]
			end
		end,
		__call = new
	}
	setmetatable(class, classType)
	return class
end
