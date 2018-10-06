--[[
	*** Constructing classes
	Class() - Creates a new class
	Class(parent) - Creats a subclass of parent

	*** Instantiating objects
	MyClass(...) - Instantiates an object. All arguments are passed to the constructor

	*** Special Properties on classes
	MyClass.ClassName - string: The name of the class, used in the default tostring
	function MyClass:constructor(...) - called when an object is instantiated
	function MyClass:toString() - called when an object is converted to a string with tostring
	function MyClass:isEqual(other) - Called to resolve comparisons with the == operator
	function MyClass:getType() - Returns the class object used to create this object.
	function MyClass:isType(classOrInterface) - Returns true if this class extends or implements the given class or interface


]]
--[[
	Creats a class. There aren't real classes in lua so these classes are just tables with some metatable voodoo
	For detailed information on how classes work, check the readme.

	parent: the parent class which this one can inherit methods and default values from
]]
Class = {}

local classIndex = {}
local classMeta = {
	__index = classIndex
}

setmetatable(Class, classMeta)

function classMeta.__call(_, parent, ...)
	local class = {}
	local interfaces = {}

	if (parent ~= nil) then
		if (parent.isInterface) then
			interfaces = {parent, ...}
			parent = nil
		else
			interfaces = {...}
		end
	end

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

	function class.isOrInherits(typ)
		if (class == typ) then
			return true
		end

		for i, v in pairs(interfaces) do
			if (v.isOrInherits(typ)) then
				return true
			end
		end

		if (parent == nil) then
			return false
		end

		return parent.isOrInherits(typ)
	end

	function class:isType(typ)
		if (self == typ) then
			error('Called isType on class, did you use "." instead of ":"?')
		end

		return class.isOrInherits(typ)
	end

	function class:constructor(...)
		if (parent and parent.constructor) then
			parent.constructor(self, ...)
		end
	end
	function class:assertImplementation()
		for _, interface in pairs(interfaces) do
			interface.assertImplementation(self)
		end
	end

	local classMeta
	classMeta = {
		__index = parent or
			{
				isClass = true
			},
		__newindex = function(t, k, v)
			if (k == 'isClass') then
				error("Can't override isClass", 2)
			end

			return rawset(t, k, v)
		end,
		__call = function(_, ...)
			-- First argument is always class
			local object = setmetatable({}, objectMeta)

			if (type(class.ClassName) ~= 'string') then
				print('warning: ClassName not set on class')
				printStackTrace(1)
			end

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

	isType('hello', 'string') -- true
	isType(Nav, Navigator) -- true
	isType(Mov, Navigator) -- false

	obj: the object (or primative) to check
	typ: the type it should be
]]
function isType(obj, typ)
	if (type(typ) ~= 'string' and (type(typ) ~= 'table' or type(typ.getType) ~= 'function')) then
		error('typ must be a string or class', 2)
	end

	local ok = true

	if (type(typ) == 'string') then
		if (typ == 'int') then
			ok = type(obj) == 'number' and obj == math.floor(obj)
		elseif (type(obj) ~= typ) then
			ok = false
		end
	else
		if (type(obj) ~= 'table') then
			ok = false
		elseif (obj.isClass) then
			ok = obj:isType(typ)

			if (type(ok) ~= 'boolean') then
				ok = false
			end
		else
			ok = false
		end
	end

	return ok
end

--[[
	Throws an error if isType returns false

	assertType(Mov, Navigator)
	-- assertType failed "Move: 011FA5B8" is not a "Class: Navigator"

	obj: see isType
	typ: see isType
	err: the error message to be thrown
	startFrame: what stack level to print the error for
	frames: how many stack frames to print (in addition to the error thrown)
]]
function assertType(obj, typ, err, startFrame, frames)
	if (type(err) ~= 'string') then
		err = 'assertType failed "' .. tostring(obj) .. '" is not a "' .. tostring(typ) .. '"'
	end

	if (type(frames) ~= 'number') then
		frames = 1
	end

	if (type(startFrame) ~= 'number') then
		startFrame = 1
	end

	local ok = isType(obj, typ)

	if (not ok) then
		if (frames) then
			printStackTrace(frames, startFrame + 2)
		end
		error(err, startFrame + 1)
	end

	return obj
end
