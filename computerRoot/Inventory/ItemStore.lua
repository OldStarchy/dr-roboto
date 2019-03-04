ItemStore = Class()
ItemStore.ClassName = 'ItemStore'

function ItemStore:constructor(size)
	assertType(size, 'int')

	if (size < 1) then
		error('Invalid storage size "' .. tostring(size) .. '"', 2)
	end

	self._size = size

	self._items = {}

	self._stateStack = {}
end

function ItemStore:pushState()
	table.insert(self._stateStack, cloneTable(self._items, 2))
end

function ItemStore:popState()
	if (#self._stateStack == 0) then
		error('Too many calls to ItemStore:popState', 2)
	end

	self._items = table.remove(self._stateStack)
end

function ItemStore:size()
	return self._size
end

function ItemStore:add(item, count)
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

function ItemStore:remove(itemSelector, count)
	assertType(itemSelector, 'string')
	self:pushState()
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
			self._items = self:popState()
			return removed
		end

		i = i + 1
	end

	if (count > 0) then
		self:popState()
		return false
	end

	return removed
end

function ItemStore:isEmpty()
	if
		(self:getFirst(
			function(self, slot)
				return self:getItemCount(slot) ~= 0
			end
		))
	 then
		return false
	end

	return true
end

function ItemStore:getFirst(delegate)
	return self:getNext(delegate, 0)
end

function ItemStore:getNext(delegate, last)
	last = last or 0
	for i = last + 1, self:size() do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function ItemStore:getLast(delegate) --GOOD
	for i = self:size(), 1, -1 do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function ItemStore:getPrevious(delegate, last) --GOOD
	last = last or self:size() + 1
	for i = last - 1, 1, -1 do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function ItemStore:getItemAt(slot)
	if self._items[slot] == nil then
		return nil
	else
		return self._items[slot].name
	end
end

function ItemStore:getItemCount(slot)
	return ((self._items[slot] and self._items[slot].count) or 0)
end

function ItemStore:getItemSpace(slot, item)
	local _item = self:getItemAt(slot) or item
	local stackSize = ItemInfo.Instance:getStackSize(_item)
	local items = self:getItemCount(slot)

	return stackSize - items
end

--[[
	return the first avaiable index of a free slot for the provided item
	]]
function ItemStore:firstAvailable(item)
	return self:nextAvailable(item, 0)
end

--[[
	return the next avaiable index of a free slot for the provided item and starting index
	]]
function ItemStore:nextAvailable(item, from)
	from = from or 0
	for i = from + 1, self:size() do
		if self._items[i] == nil then
			return i, ItemInfo.Instance:getStackSize(item)
		elseif self._items[i].name == item then
			if (ItemInfo.Instance:getStackSize(item) - self._items[i].count > 0) then
				return i, ItemInfo.Instance:getStackSize(item) - self._items[i].count
			end
		end
	end
	return nil
end

--[[
	returns the total avaiable space in the chest for this item
]]
function ItemStore:getTotalSpaceFor(item)
	local count = 0
	local i = self:firstAvailable(item)
	local spare = self:getItemSpace(i, item)

	while i ~= nil do
		count = count + spare
		i = self:nextAvailable(item, i)
		spare = self:getItemSpace(i, item)
	end

	return count
end

--[[
	verifies if it can push an item into the chest
]]
function ItemStore:canPush(item, count)
	assert(item ~= nil, 'cannot check for nil item')
	assertType(count, 'int', 'count is required and a number')

	if (count == 0) then
		return true
	end

	local c = self:getTotalSpaceFor(item) - count
	if c >= 0 then
		return true
	else
		return false, -c
	end
end

--[[
	pushes an item into the chest at the next space available.
	will return false, 'error desc' if failed.
]]
function ItemStore:push(item, count)
	assert(item ~= nil, 'cannot check for nil item')
	assertType(count, 'int', 'count is required and a number')

	if (count == 0) then
		return true
	end

	if (self:getTotalSpaceFor(item) < count) then
		return false, 'Not enough space for items'
	end
	local i = self:firstAvailable(item)
	spare = self:getItemSpace(i, item)
	local moved = 0
	while (i ~= nil and moved < count) do
		if spare > (count - moved) then
			spare = (count - moved)
		end
		if (self._items[i] == nil) then
			--TODO metadata/damage needs to be stored
			self._items[i] = ItemStackDetail(item, 0, spare)
		else
			self._items[i].count = self._items[i].count + spare
		end
		moved = moved + spare

		i = self:nextAvailable(item, i)
		spare = self:getItemSpace(i, item)
	end
	if (moved < count) then
		return false, 'Not enough space for items (some moved)'
	end
	return true
end

--[[
	returns true if the chest contains item by exact name
]]
function ItemStore:has(item)
	for i = 1, self:size() do
		if self._items[i] then
			if self._items[i].name == item then
				return true
			end
		end
	end
	return false
end

--[[
	returns top item in chest stack
	returns name, count
]]
function ItemStore:peek()
	for i = 1, self:size() do
		if self._items[i] then
			return self._items[i].name, self._items[i].count
		end
	end
end

--[[
	returns and removes top item in chest stack
	returns name, count
]]
function ItemStore:pop()
	local r = nil
	for i = 1, self:size() do
		if self._items[i] then
			r = self._items[i]
			self._items[i] = nil
			break
		end
	end
	return r.name, r.count
end

--[[
	clears information about contents of chest
]]
function ItemStore:clear()
	self._items = nil
end

function ItemStore:print(start)
	start = start or 1
	local lim = self:size()
	if lim > start + 10 then
		lim = start + 10
	end
	for i = start, lim do
		if self._items[i] then
			print(i .. ': ' .. self._items[i].count .. ' ' .. self._items[i].name)
		end
	end
end

--[[
--Taken from the old CQL library. Don't think it really
--belongs in ItemStore but not sure where to put it yet

--Cycles through items in "this" chest putteng them into a
--temp chest untill the requested slot has been reached, then
--puts all the other items back in "this" chest

function index(side, name, isDouble)
	if not side then
		side = ''
	end
	debugger.assert(side == '' or side == 'Up' or side == 'Down')
	if not inv.push('minecraft:chest') then
		inv.pop()
		return nil, 'Need a chest'
	end

	if turtle.getItemCount() ~= 1 then
		if not inv.push() then
			inv.pop()
			inv.pop()
			return nil, 'Need an empty slot to cycle items'
		end
		inv.pop()
	end

	local chestOptions = {Up = true, Down = true, [''] = true}
	chestOptions[side] = nil
	local chestpos = nil
	for i, v in pairs(chestOptions) do
		if not turtle['detect' .. i]() then
			chestPos = i
			break
		end
	end

	if not chestPos then
		return nil, 'No room to place chest'
	end

	turtle['place' .. chestPos]()
	inv.select()

	local function cycleOut()
		local a = turtle['suck' .. side]()
		turtle['drop' .. chestPos]()
		return a
	end

	local chest = Chest.new(name, isDouble)
	local function cycleIn()
		turtle['suck' .. chestPos]()
		local deets = turtle.getItemDetail()
		chest:push(deets.name .. tostring(deets.damage), deets.count)
		turtle['drop' .. side]()
	end

	local stacks = 0
	while cycleOut() and stacks < 27 do
		stacks = stacks + 1
	end

	for i = 1, stacks do
		cycleIn()
	end

	turtle['dig' .. chestPos]()
	return chest
end
]]
