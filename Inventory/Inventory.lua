Inventory = Class()
Inventory.ClassName = 'Inventory'

function Inventory:constructor()
	self._items = {}

	self._stack = {}
end

function Inventory:push()
	table.insert(self._stack, cloneTable(self._items, 2))
end

function Inventory:pop()
	assert(#self._stack > 0, 'Too many calls to Inventory:pop')

	local oldItems = self._items
	self._items = table.remove(self._stack)
	return oldItems
end

function Inventory:add(item, count)
	assertType(item, 'table')

	--TODO: maybe create itemStack class? discussion required
	table.insert(
		self._items,
		{
			name = item.name,
			damage = item.damage,
			count = count or item.count
		}
	)
end

function Inventory:remove(itemSelector, count)
	assertType(itemSelector, 'string')
	self:push()
	local removed = {}

	local i = 1

	while (i < #self._items) do
		local item = self._items[i]
		if (InventoryManager.ItemIs(item, itemSelector)) then
			if (item.count <= count) then
				table.insert(removed, item)
				count = count - item.count
				table.remove(self._items, i)
			else
				table.insert(
					removed,
					{
						name = item.name,
						damage = item.damage,
						count = count
					}
				)
				item.count = item.count - count
				count = 0
			end
		end

		if (count == 0) then
			self._items = self:pop()
			return removed
		end

		i = i + 1
	end

	if (count > 0) then
		self:pop()
		return false
	end

	return removed
end
