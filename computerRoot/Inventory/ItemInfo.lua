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
	assertType(item, 'string')

	return self._data[item] or 64
end

function ItemInfo:setStackSize(item, size)
	assertType(item, 'string')
	assertType(size, 'int')

	if (size <= 0) then
		error('Invalid stack size "' .. tostring(size) .. '"', 2)
	end

	self._data[item] = size
end
