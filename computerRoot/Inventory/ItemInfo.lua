ItemInfo = Class()
ItemInfo.ClassName = 'ItemInfo'
ItemInfo.Instance = nil

ItemInfo._default = 64

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

	if (item == nil) then
		return self._default
	end

	for name, size in pairs(self._data) do
		if (item:matches(name)) then
			return self._data[name]
		end
	end

	return self._default
end

function ItemInfo:setStackSize(itemSelector, size)
	assertType(itemSelector, 'string')
	assertType(size, 'int')

	if (size <= 0) then
		error('Invalid stack size "' .. tostring(size) .. '"', 2)
	end

	itemSelector = ItemDetail.NormalizeId(itemSelector)

	self._data[itemSelector] = size
end
