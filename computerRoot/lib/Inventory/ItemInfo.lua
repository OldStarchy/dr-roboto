ItemInfo = Class()
ItemInfo.ClassName = 'ItemInfo'
ItemInfo.Instance = nil

ItemInfo._default = {
	stackSize = 64
	--no burn time
}

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
	ii.ev:suppress(true)

	for i, v in pairs(obj) do
		assertType(v, 'table')

		if (v.stackSize ~= nil) then
			ii:setStackSize(i, v.stackSize)
		end

		if (v.burnTime ~= nil) then
			ii:setBurnTime(i, v.burnTime)
		end
	end

	ii.ev:suppress(false)
	return ii
end

function ItemInfo:_get(item, key)
	if (type(item) == 'string') then
		item = ItemDetail.FromId(item)
	end

	if (item == nil) then
		return self._default[key]
	end

	for name, size in pairs(self._data) do
		if (item:matches(name)) then
			return self._data[name][key]
		end
	end

	return self._default[key]
end

function ItemInfo:_set(itemSelector, key, value)
	assertType(itemSelector, 'string')
	assertType(value, 'int')

	if (value <= 0) then
		error('Invalid "' .. key .. '" "' .. tostring(value) .. '"', 2)
	end

	itemSelector = ItemDetail.NormalizeId(itemSelector)

	if (self._data[itemSelector] == nil) then
		self._data[itemSelector] = {}
	end

	self._data[itemSelector][key] = value

	self.ev:trigger('state_changed')
end

function ItemInfo:getStackSize(item)
	return self:_get(item, 'stackSize')
end

function ItemInfo:getBurnTime(item)
	return self:_get(item, 'burnTime')
end

function ItemInfo:setStackSize(itemSelector, size)
	self:_set(itemSelector, 'stackSize', size)
end

function ItemInfo:setBurnTime(itemSelector, time)
	self:_set(itemSelector, 'burnTime', time)
end
