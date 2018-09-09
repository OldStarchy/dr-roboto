function Class(parent)
	local class = {}

	function class.constructor(...)
		if (parent and parent.constructor) then
			parent.constructor(...)
		end
	end

	local classType = {
		__index = function(class, key)
			if (key == 'new') then
				return function(...)
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
			else
				return rawget(class, key) or parent and parent[key]
			end
		end
	}
	setmetatable(class, classType)
	return class
end
