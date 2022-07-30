includeOnce './IBuffer'

StringBuffer = Class(IBuffer)
StringBuffer.ClassName = 'StringBuffer'

function StringBuffer:constructor(initial, length)
	self._length = assertType(length, 'int', nil, 3)
	self._buffer = {}

	assert(length > 0, 'StringBuffer length must be > 0')
	assertType(initial, 'string', 'Initial value for string buffer must be 1 character')
	assert(#initial == 1, 'Initial value for string buffer must be 1 character')

	self:fill(initial)
end

function StringBuffer:fill(char, start, ed)
	assertType(char, 'string', 'Fill value for string buffer must be 1 character')
	assert(#char == 1, 'Fill value for string buffer must be 1 character')

	start = assertType(coalesce(start, 1), 'int')
	ed = assertType(coalesce(ed, self._length), 'int')

	start = math.clamp(1, start, self._length)
	ed = math.clamp(1, ed, self._length)

	if (start >= ed) then
		return
	end

	for i = start, ed do
		self._buffer[i] = char
	end
end
function StringBuffer:write(str, start, ed)
	assertType(str, 'string')
	start = assertType(coalesce(start, 1), 'int')
	ed = assertType(coalesce(ed, start + #str - 1), 'int')

	if (start > self._length) then
		return
	end

	if (ed < 1) then
		return
	end

	local skip = 0
	if (start < 1) then
		skip = 1 - start
		start = 1
	end

	ed = math.min(ed, self._length)

	if (start > ed) then
		return
	end

	local length = ed - start + 1

	if (#str < length) then
		length = #str
		ed = start + length - 1
	end

	for i = 1, length do
		self._buffer[i + start - 1] = str:sub(i + skip, i + skip)
	end
end

function StringBuffer:read(start, ed)
	start = assertType(coalesce(start, 1), 'int')
	ed = assertType(coalesce(ed, self._length), 'int')
	start = math.max(start, 1)
	ed = math.min(ed, self._length)

	if (start > ed) then
		return ''
	end

	local r = ''
	for i = start, ed do
		r = r .. self._buffer[i]
	end

	return r
end
