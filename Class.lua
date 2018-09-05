
local CreateClass = function(parent)
	local class = {}
	local classType = {
		__index = {
			new = function(self, ...)
				local object = setmetatable({}, class)

				if (class.constructor ~= nil) then
					class.constructor(object, ...)
				end

				return object
			end
		}
	}
	setmetatable(class, classType)
	return class
end

return CreateClass
