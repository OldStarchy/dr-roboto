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
		frame = 2
	end

	if (type(typ) == 'table' and typ.isInterface) then
		return typ.assertImplementation(obj, err, frame + 1)
	end

	if (typ == nil) then
		error('typ must not be nil', frame + 1)
	end

	if (not isType(obj, typ)) then
		error(err, frame + 1)
	end

	return obj
end
