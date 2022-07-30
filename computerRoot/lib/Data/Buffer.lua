includeOnce('./IBuffer')

Buffer = Class(IBuffer)
Buffer.ClassName = 'Buffer'

function Buffer:constructor(initial, length)
	self._length = assertType(length, 'int')
	self._buffer = {}
	self:fill(initial)
end

function Buffer:fill(val, start, ed)
	start = assertType(coalesce(start, 1), 'int')
	ed = assertType(coalesce(ed, self._length), 'int')

	start = math.clamp(1, start, self._length)
	ed = math.clamp(1, ed, self._length)

	if (start >= ed) then
		return
	end

	for i = start, ed do
		self._buffer[i] = val
	end
end

function Buffer:write(values, start, ed)
	assertType(values, 'table')
	start = assertType(coalesce(start, 1), 'int')
	ed = assertType(coalesce(ed, start + #values - 1), 'int')

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

	if (#values < length) then
		length = #values
		ed = start + length - 1
	end

	for i = 1, length do
		self._buffer[i + start - 1] = values[i + skip]
	end
end

function Buffer:read(start, ed)
	start = assertType(coalesce(start, 1), 'int')
	ed = assertType(coalesce(ed, self._length), 'int')
	start = math.max(start, 1)
	ed = math.min(ed, self._length)

	if (start > ed) then
		return ''
	end

	local r = {}
	for i = start, ed do
		table.insert(r, self._buffer[i])
	end

	return r
end
