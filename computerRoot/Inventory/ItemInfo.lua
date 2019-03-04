ItemInfo = Class()
ItemInfo.ClassName = 'ItemInfo'
ItemInfo.Instance = nil

function ItemInfo:constructor()
	self._data = {}

	self.ev = EventManager()
end

function ItemInfo:serialize()
	return cloneTable(self._data, 2)
end

function ItemInfo.Deserialize(obj)
	assertType(obj, 'table')

	local ii = ItemInfo()

	for i, v in pairs(obj) do
		ii:setStackSize(i, v)
	end

	return ii
end

function ItemInfo:getStackSize(item)
	if (type(item) == 'string') then
		item = ItemDetail.FromId(item)
	end

	assertType(item, ItemDetail, 'Must be string or ItemDetail', 2)

	for name, size in pairs(self._data) do
		if (item:matches(name)) then
			return self._data[name]
		end
	end

	return 64
end

function ItemInfo:setStackSize(itemSelector, size)
	assertType(itemSelector, 'string')
	assertType(size, 'int')

	if (size <= 0) then
		error('Invalid stack size "' .. tostring(size) .. '"', 2)
	end

	self._data[itemSelector] = size
end
