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
