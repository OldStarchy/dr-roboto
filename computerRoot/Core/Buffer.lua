Buffer = Class(IBuffer)
Buffer.ClassName = 'Buffer'

function Buffer:constructor(initial, length)
	self._length = assertType(length, 'int')
	self._buffer = {}
	self:fill(initial)
end

function Buffer:fill(val)
	for i = 1, self._length do
		self._buffer[i] = val
	end
end

function Buffer:write(values, start, ed)
	assertType(values, 'table')
	start = coalesce(start, 1)
	ed = coalesce(ed, start + #values - 1)
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

	if (#values < length) then
		length = #values
		ed = start + length - 1
	end

	for i = 1, length do
		self._buffer[i + start] = values[i + skip]
	end
end

function Buffer:read(start, ed)
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

	local r = {}
	for i = 1, length do
		table.insert(r, self._buffer[i + start])
	end

	return r
end
