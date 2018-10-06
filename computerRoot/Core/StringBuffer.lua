StringBuffer = Class(IBuffer)
StringBuffer.ClassName = 'StringBuffer'

function StringBuffer:constructor(initial, length)
	self._length = assertType(length, 'int')
	self._buffer = {}

	assert(length > 0, 'StringBuffer length must be > 0')
	assertType(initial, 'string', 'Initial value for string buffer must be 1 character')
	assert(#initial == 1, 'Initial value for string buffer must be 1 character')

	self:fill(initial)
end

function StringBuffer:fill(char)
	assertType(char, 'string', 'Fill value for string buffer must be 1 character')
	assert(#char == 1, 'Fill value for string buffer must be 1 character')

	for i = 1, self._length do
		self._buffer[i] = char
	end
end

function StringBuffer:write(str, start, ed)
	assertType(str, 'string')
	start = coalesce(start, 1)
	ed = coalesce(ed, start + #str - 1)
	assertType(start, 'int')
	assertType(ed, 'int')

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

	if (start >= ed) then
		return
	end

	local length = ed - start + 1

	if (#str < length) then
		length = #str
		ed = start + length - 1
	end

	for i = 1, length do
		self._buffer[i + start] = str:sub(i + skip, i + skip)
	end
end

function StringBuffer:read(start, ed)
	start = coalesce(start, 1)
	ed = coalesce(ed, self._length)
	assertType(start, 'int')
	assertType(ed, 'int')
	start = math.max(start, 1)
	ed = math.min(ed, self._length)

	if (start > ed) then
		return ''
	end
	local length = ed - start + 1

	local r = ''
	for i = 1, length do
		r = r .. self._buffer[i + start]
	end

	return r
end
