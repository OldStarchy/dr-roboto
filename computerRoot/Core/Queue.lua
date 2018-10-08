Queue = Class()
Queue.ClassName = 'Queue'

function Queue:constructor(compareDelagate)
	self._queue = {}

	if (compareDelagate ~= nil) then
		self._compareDelagate = assertType(defaultCompareDelagate, 'function')
	else
		self._compareDelagate = nil
	end
end

function Queue:enqueue(item)
	table.insert(self._queue, item)

	if (self._compareDelagate ~= nil) then
		self._queue = table.sort(self._queue, self._compareDelagate)
	end
end

function Queue:dequeue()
	return table.remove(1)
end

function Queue:getItems()
	return cloneTable(self._queue)
end

--TODO: remove this, but its used in task manager right now
function Queue:remove(index)
	assertType(index, 'int')

	table.remove(self._queue, index)
end
