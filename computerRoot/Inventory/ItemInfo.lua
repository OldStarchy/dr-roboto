ItemInfo = Class()
ItemInfo.ClassName = 'ItemInfo'
ItemInfo.Instance = nil

function ItemInfo:constructor()
	self._data = {}
end

function ItemInfo:loadHardTable(filename)
	assertType(filename, 'string')

	self._data = hardTable(filename)
end

function ItemInfo:getStackSize(item)
	return self._data[item] or 64
end

function ItemInfo:setStackSize(item, size)
	self._data[item] = size
end
