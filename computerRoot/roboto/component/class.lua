--[[
	Creats a class. There aren't real classes in lua so these classes are just tables with some metatable voodoo
	For detailed information on how classes work, check the docs.

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
	local implementationAsserted = false

	class.ChildTypes = {}
	class.DefinitionLocation = getStackFrame(2)
	if (parent ~= nil) then
		if (parent.isInterface) then
			interfaces = {parent, ...}
			parent = nil
		else
			interfaces = {...}

			table.insert(parent.ChildTypes, class)
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

	function class:conversionConstructor(...)
		if (parent and parent.conversionConstructor) then
			parent.conversionConstructor(self, ...)
		end
	end

	function class:assertImplementation()
		implementationAsserted = true
		for _, interface in pairs(interfaces) do
			interface.assertImplementation(self)
		end
		return self
	end

	local classMeta
	classMeta = {
		__index = setmetatable(
			{
				isClass = true,
				convertToInstance = function(tbl, ...)
					if (type(tbl) ~= 'table') then
						error("Can't convert " .. type(tbl) .. ' to ' .. tostring(class), 2)
					end

					if
						(not pcall(
							function()
								setmetatable(tbl, objectMeta)
							end
						))
					 then
						error("Couldn't set metatable when converting table to " .. tostring(class), 2)
					end

					if (class.conversionConstructor ~= nil) then
						class.conversionConstructor(tbl, ...)
					end

					return tbl
				end
			},
			{__index = parent}
		),
		__newindex = function(t, k, v)
			if (k == 'isClass') then
				error("Can't override isClass", 2)
			end

			return rawset(t, k, v)
		end,
		__call = function(_, ...)
			if (not implementationAsserted) then
				class:assertImplementation()
			end

			if (type(class.ClassName) ~= 'string') then
				print('warning: ClassName not set on class')
				printStackTrace(1)
			end

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

function classIndex.LoadOrNew(file, class, ...)
	if (fs.exists(file)) then
		local tbl = fs.readTableFromFile(file)
		if (tbl) then
			return class.Deserialise(tbl)
		else
			error('Could not read from file "' .. file .. '"', 2)
		end
	end

	return class(...)
end
