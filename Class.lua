local CreateClass = function(parent)
	local class = {}
	local classType = {
		__index = {
			new = function(...)
				local args = {...}
				local object = setmetatable({}, {__index = class})

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
