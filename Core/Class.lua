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
				if (class.ClassName ~= nil) then
					result = tostring(self):gsub('table', class.ClassName)
				else
					result = tostring(self):gsub('table', 'class')
				end
			end

			objectMeta.__tostring = oldToString
			return result
		end,
		__eq = function(self, other)
			local oldEq = objectMeta.__eq
			-- Allow native == to work
			objectMeta.__eq = nil

			local result = ''
			if (type(class.isEqual) == 'function') then
				result = class.isEqual(self, other)
			else
				result = self == other
			end

			objectMeta.__eq = oldEq
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

	local classMeta
	classMeta = {
		__index = parent,
		__call = function(_, ...)
			-- First argument is always class
			local object = setmetatable({}, objectMeta)

			if (class.constructor ~= nil) then
				class.constructor(object, ...)
			end

			return object
		end,
		__tostring = function()
			local oldToString = classMeta.__tostring
			-- Allow native tostring to work
			classMeta.__tostring = nil

			local result = ''
			if (class.ClassName ~= nil) then
				result = 'Class: ' .. class.ClassName
			else
				result = tostring(class):gsub('table', 'Class')
			end

			classMeta.__tostring = oldToString
			return result
		end
	}
	setmetatable(class, classMeta)
	return class
end

--[[
	Checks if something is something. Can test for primative types, or class types.

	assert('hello', 'string')
	assert(Nav, Navigator)
	assert(Mov, Navigator)
	-- assertType failed "Move: 011FA5B8" is not a "Class: Navigator"

	obj: the object (or primative) to check
	typ: the type it should be
	err: the error message to be thrown
	startFrame: what stack level to print the error for
	frames: how many stack frames to print (in addition to the error thrown)
]]
function assertType(obj, typ, err, startFrame, frames)
	if (type(typ) ~= 'string' and (type(typ) ~= 'table' or type(typ.getType) ~= 'function')) then
		error('typ must be a string or class', 2)
	end

	if (type(err) ~= 'string') then
		err = 'assertType failed "' .. tostring(obj) .. '" is not a "' .. tostring(typ) .. '"'
	end

	if (type(frames) ~= 'number') then
		frames = 1
	end

	if (type(startFrame) ~= 'number') then
		startFrame = 1
	end

	local ok = true
	local typeString = ''

	if (type(typ) == 'string') then
		typeString = typ

		if (type(obj) ~= typ) then
			ok = false
		end
	else
		typeString = tostring(typ)
		if (type(obj) ~= 'table') then
			ok = false
		elseif (type(obj.isType) ~= 'function') then
			ok = false
		else
			ok = obj:isType(typ)
		end
	end

	if (not ok) then
		if (frames) then
			printStackTrace(frames, startFrame + 2)
		end
		error(err, startFrame + 1)
	end
end
