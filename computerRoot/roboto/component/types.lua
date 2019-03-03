--[[
	Checks if something is something. Can test for primative types, or class types.

	isType('hello', 'string') -- true
	isType(nav, Navigator) -- true
	isType(mov, Navigator) -- false

	obj: the object (or primative) to check
	typ: the type it should be
]]
function isType(obj, typ)
	if (type(typ) ~= 'string' and (type(typ) ~= 'table' or not typ.isClass)) then
		if (typ == Class) then
			return type(obj) == 'table' and obj.isClass == true
		else
			return false
		end
		error('typ must be a string or class', 2)
	end

	local ok = true

	if (type(typ) == 'string') then
		if (typ == 'int') then
			ok = type(obj) == 'number' and obj == math.floor(obj)
		elseif (typ == 'char') then
			ok = type(obj) == 'string' and #obj == 1
		elseif (type(obj) ~= typ) then
			ok = false
		end
	else
		if (type(obj) ~= 'table') then
			ok = false
		elseif (obj.isClass) then
			ok = obj.isOrInherits(typ)

			if (type(ok) ~= 'boolean') then
				ok = false
			end
		else
			ok = false
		end
	end

	--TODO: interfaces
	return ok
end

--[[
	Throws an error if isType returns false

	assertType(mov, Navigator)
	-- assertType failed "Move: 011FA5B8" is not a "Class: Navigator"

	obj: see isType
	typ: see isType
	err: the error message to be thrown
	frame: the stack frame on which to throw
]]
function assertType(obj, typ, err, frame)
	if (type(err) ~= 'string') then
		err = 'assertType failed "' .. tostring(obj) .. '" is not a "' .. tostring(typ) .. '"'
	end

	if (type(frame) ~= 'number') then
		frame = 1
	end

	if (type(typ) == 'table' and typ.isInterface) then
		return typ.assertImplementation(obj, err, frame + 1)
	end

	if (typ == nil) then
		error('typ must not be nil', 2)
	end

	if (not isType(obj, typ)) then
		error(err, frame + 1)
	end

	return obj
end
