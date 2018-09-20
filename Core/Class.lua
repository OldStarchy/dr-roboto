--[[
	Creats a class. There aren't real classes in lua so these classes are just tables with some metatable voodoo
	For detailed information on how classes work, check the readme.

	parent: the parent class which this one can inherit methods and default values from
]]
function Class(parent)
	local class = {}

	local objectMeta = nil
	-- Declare objectMeta before creating the table to make sure objectMeta is in-scope for __tostring
	objectMeta = {
		__index = class,
		__tostring = function(self)
			local oldToString = objectMeta.__tostring
			-- Allow native tostring to work
			objectMeta.__tostring = nil

			local result = ''
			if (type(class.toString) == 'function') then
				result = class.toString(self)
			else
				result = tostring(self):gsub('table', 'class')
			end

			objectMeta.__tostring = oldToString
			return result
		end
	}

	function class:getType()
		return class
	end

	function class:isType(clazz)
		if (self == clazz) then
			error('Called isType on class, did you use "." instead of ":"?')
		end

		if (class == clazz) then
			return true
		elseif (parent == nil) then
			return false
		else
			return parent.isType(self, clazz)
		end
	end

	function class:constructor(...)
		if (parent and parent.constructor) then
			parent.constructor(self, ...)
		end
	end

	local classMeta = {
		__index = parent,
		__call = function(_, ...)
			-- First argument is always class
			local object = setmetatable({}, objectMeta)

			if (class.constructor ~= nil) then
				class.constructor(object, ...)
			end

			return object
		end
	}
	setmetatable(class, classMeta)
	return class
end
