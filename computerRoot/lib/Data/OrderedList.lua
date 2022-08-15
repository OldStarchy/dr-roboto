OrderedList = Class()
OrderedList.ClassName = 'OrderedList'

function OrderedList:constructor()
	self._data = {}
end

function OrderedList:insert(item)
	table.insert(self._data, item)
end

function OrderedList:getItems()
	return self._data
end

function OrderedList:pop()
	local minScore = 100000000
	local minId = 1

	for i, v in ipairs(self._data) do
		if (self._data[i].score < minScore) then
			minScore = self._data[i].score
			minId = i
		end
	end

	return table.remove(self._data, minId)
end

function OrderedList:peek()
	local item = self:pop()
	self:insert(item)
	return item
end

function OrderedList:count()
	return #self._data
end
