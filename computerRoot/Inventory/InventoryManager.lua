InventoryManager = Class()
InventoryManager.ClassName = 'InventoryManager'

--[[
	Checks if an item matches an item selector.

	item can either be an object with a name and damage value (eg. from turtle.getItemDetail())
	or a number, and it will call turtle.getItemDetail() for you

	An item selector is a string in the form 'namespace:item:damage'
	eg. dirt is 'minecraft:dirt:0', oak 'minecraft:log:0', and birch 'minecraft:log:2'

	Namespace can be omited, or namespace and damage can be omitted
	'dirt:0' or 'dirt' is ok
	'minecraft:dirt' is not ok

	Omitted parts default to a wildcard
	'dirt' == 'dirt:*' == '*:dirt:*'
]]
function InventoryManager.ItemIs(item, selector)
	if (type(item) == 'number') then
		item = Inv:getItemDetail(item)
	end

	if (item == nil) then
		return false
	end

	if (not isType(item, ItemDetail)) then
		item = ItemStackDetail.convertToInstance(cloneTable(item, 3))
	end

	return item:matches(selector)
end

function InventoryManager:_fixSlot(slot) --GOOD
	if type(slot) ~= 'number' then
		return self._turtle.getSelectedSlot()
	else
		if slot > 16 or slot < 1 then
			error('Invalid Slot', 3)
		else
			return slot
		end
	end
end

function InventoryManager:constructor(turtle)
	self._turtle = turtle
	self._oldTurtle = {}

	self._locked = {}
	self._selectionStack = {}
	self:_attach()

	local this = self

	function self._delContaining(selector)
		return function(slot)
			local stack = this:getItemDetail(slot)

			return stack and stack:matches(selector) or (selector == nil)
		end
	end

	function self._delSameAs(slot)
		if this._turtle.getItemCount(slot) == 0 then
			if this._turtle.getItemCount() == 0 then
				return true
			end

			return false
		end
		return this._turtle.compareTo(slot)
	end

	function self._delEmpty(slot)
		return this._turtle.getItemCount(slot) == 0
	end

	function self._delContainingFree(selector)
		return function(slot)
			return this:getFreeItemCount(slot) > 0 and self:getItemDetail(slot):matches(selector)
		end
	end
end

function InventoryManager:_attach()
	local this = self
	local overrideFunctionsList = {
		'inspect',
		'getItemDetail',
		'select',
		'transferTo'
	}

	for _, func in ipairs(overrideFunctionsList) do
		self._oldTurtle[func] = self._turtle[func]
		self._turtle[func] = function(...)
			return this[func](this, unpack({...}))
		end
	end
end

function InventoryManager:pushSelection(newSel) --GOOD
	self._selectionStack[#self._selectionStack + 1] = self._turtle.getSelectedSlot()
	if (newSel ~= nil) then
		self:select(newSel)
	end
end

function InventoryManager:popSelection() --GOOD
	if #self._selectionStack > 0 then
		self:select(self._selectionStack[#self._selectionStack])
	end
	self._selectionStack[#self._selectionStack] = nil
end

function InventoryManager:inspect()
	local exists, data = self._oldTurtle.inspect()

	print('converting to blockdetail')
	return exists, BlockDetail.convertToInstance(data)
end

function InventoryManager:getItemDetail(selector)
	local slot = self:findItemSlot(selector)
	local data = self._oldTurtle.getItemDetail(slot)

	if (data == nil) then
		return nil
	end

	local itemDetail = ItemStackDetail.convertToInstance(data)

	itemDetail.stackSize = self._oldTurtle.getItemCount(slot) + self._oldTurtle.getItemSpace(slot)
	itemInfo:setStackSize(itemDetail.name, itemDetail.stackSize)

	return itemDetail
end

function InventoryManager:findItemSlot(selector)
	if (selector == nil) then
		return nil
	end

	if (type(selector) == 'number') then
		return selector
	end

	if (type(selector) == 'string') then
		-- TODO: selector search
		error('String selections not yet implemented')
	end

	error('Invalid type passed to InventoryManager:findItemSlot', 2)
end

function InventoryManager:countItem(selector)
	local count = 0

	for i = 1, 16 do
		local item = self:getItemDetail(i)

		if (item ~= nil and item:matches(selector)) then
			count = count + item.count
		end
	end

	return count
end

function InventoryManager:select(item)
	if (type(item) == 'number') then
		return self._oldTurtle.select(item)
	end

	if (type(item) == 'string') then
		for i = 1, 16 do
			if (InventoryManager.ItemIs(i, item)) then
				return self:select(i)
			end
		end
		return false
	end

	error(type(item) .. ' passed to select not supported', 2)
end

function InventoryManager:drop()
	return self._oldTurtle.drop()
end
function InventoryManager:dropUp()
	return self._oldTurtle.dropUp()
end
function InventoryManager:dropDown()
	return self._oldTurtle.dropDown()
end

function InventoryManager:suck()
	return self._oldTurtle.suck()
end
function InventoryManager:suckUp()
	return self._oldTurtle.suckUp()
end
function InventoryManager:suckDown()
	return self._oldTurtle.suckDown()
end

--Returns (Was something moved?, how many was moved, how many left here)
function InventoryManager:_transferTo(slot, count) --GOOD
	local currentItemCount = self._turtle.getItemCount()

	count = coalesce(count, currentItemCount)

	if count > currentItemCount then
		count = currentItemCount
	end

	if (self._oldTurtle.transferTo(slot, count)) then
		local newCount = self._turtle.getItemCount()
		return true, currentItemCount - newCount, newCount
	end

	return false, 0, currentItemCount
end

--(int dest)
--(int dest,      int count)
--(string source, int dest)
--(int source,    int dest,  int count)
--(string source, int dest,  int count)
function InventoryManager:transferTo(from, to, count) --GOOD
	if (count == nil) then
		if (to == nil) then
			if (type(from) == 'number') then
				return self:_transferTo(from)
			else
				error('invalid arguments for transferTo', 2)
			end
		elseif (type(from) == 'number') then
			return self:_transferTo(from, to)
		elseif (type(from) == 'string') then
			if (self:hasItem(from)) then
				self:pushSelection(self:getFirstContaining(from))
				local r = {self:_transferTo(to)}
				self:popSelection()
				return table.unpack(r)
			else
				error("Can't take " .. from .. ' because there is none')
			end
		end
	elseif (type(from) == 'number') then
		self:pushSelection(from)
		local r = {self:_transferTo(to, count)}
		self:popSelection()
		return table.unpack(r)
	elseif (type(from) == 'string') then
		if (self:hasItem(from)) then
			self:pushSelection(self:getFirstContaining(from))
			local r = {self:_transferTo(to, count)}
			self:popSelection()
			return table.unpack(r)
		else
			error("Can't take " .. from .. ' because there is none')
		end
	end
end

function InventoryManager:lock(slot, item, count)
	assertType(slot, 'int')
	assertType(item, 'string')
	count = assertType(coalesce(count, 1), 'int')

	if (self:isLocked(slot) and not self:getItemDetail(slot):matches(item)) then
		return false
	end

	if (count == 0) then
		return true
	end

	if (not self:have(slot, item, count)) then
		return false
	end
	self._locked[slot] = {item, count}

	return true
end

function InventoryManager:have(slot, item, count)
	assertType(slot, 'int')
	assertType(item, 'string')
	count = assertType(coalesce(count, 1), 'int')

	if (self:getTotalFreeItemCount(item) < count) then
		return false, 'Not enough items'
	end

	local stack = self:getItemDetail(slot)
	if (stack and not stack:matches(item)) then
		--Unwanted item in the way, move it out
		local co = self._turtle.getItemCount(slot)
		local ma = self._turtle.getItemSpace(slot)
		self:pushSelection(slot)

		--Find a suitable place to put these unwanted items (add to other stacks or in an empty spot)
		local allSlots = self:getAllSameAs(slot)
		for _, v in pairs(self:getAllEmpty()) do
			table.insert(allSlots, v)
		end
		for i, v in pairs(allSlots) do
			local _, mv, _ = self:transferTo(v, self._turtle.getItemSpace(v))
			co = co - mv
			if (co <= 0) then
				break
			end
		end

		--TODO: don't move items if there is not enough space to move them
		if co > 0 then
			return false
		end
	end

	local current = self._turtle.getItemCount(slot)

	local s = self:getFirstUnlockedContaining(item)
	while (current < count and s ~= nil) do
		local c = self:getFreeItemCount(s)
		if (c > (count - current)) then
			c = (count - current)
		end

		local _, co, _ = self:transferTo(s, slot, c)
		current = current + co

		if (count - current > self._turtle.getItemSpace(slot)) then
			count = self._turtle.getItemSpace(slot)
		end
		if (current >= count) then
			return true
		end
		s = self:getNextUnlockedContaining(item, s)
	end
	if (self._turtle.getItemCount(slot) >= count) then
		return true
	end
end

function InventoryManager:hasEmpty() --GOOD
	return not (not self:getFirstEmpty())
end

function InventoryManager:hasItem(itemName) --GOOD
	if itemName == nil then
		print('Calling hasItem with nil, use hasEmpty instead')
		return self:hasEmpty()
	end
	return not (not self:getFirstContaining(itemName))
end

function InventoryManager:getFirstUnlockedContaining(item) --GOOD
	return self:getFirst(self._delContainingFree(item))
end

function InventoryManager:getNextUnlockedContaining(item, index) --GOOD
	return self:getNext(self._delContainingFree(item), index)
end

function InventoryManager:getAllUnlockedContaining(item) --GOOD
	return self:getAll(self._delContaining(item))
end

function InventoryManager:unlock(slot) --GOOD
	slot = self:_fixSlot(slot)
	self._locked[slot] = nil
end

function InventoryManager:unlockAll() --GOOD
	self._locked = {}
end

function InventoryManager:getLock(slot) --GOOD
	return {table.unpack(self._locked[self:_fixSlot(slot)])}
end

function InventoryManager:isLocked(slot)
	return not (not self._locked[self:_fixSlot(slot)])
end

function InventoryManager:isUnlocked(slot) --GOOD
	return not self._locked[self:_fixSlot(slot)]
end

--[[
	Counts the number of items that hasn't been locked
]]
function InventoryManager:getTotalFreeItemCount(selector)
	local r = 0
	for _, v in pairs(self:getAllContaining(selector)) do
		r = r + self:getFreeItemCount(v)
	end
	return r
end

--[[
	Counts the number of items in a slot that have not been locked
]]
function InventoryManager:getFreeItemCount(slot)
	assertType(slot, 'int')

	return self._turtle.getItemCount(slot) - ((self._locked[slot] and self._locked[slot][2]) or 0)
end

function InventoryManager:getFirst(delegate)
	for i = 1, 16 do
		if delegate(i) then
			return i
		end
	end
	return nil
end

function InventoryManager:getLast(delegate)
	for i = 16, 1, -1 do
		if delegate(i) then
			return i
		end
	end
	return nil
end

function InventoryManager:getPrevious(delegate, last)
	last = last or 17
	for i = last - 1, 1, -1 do
		if delegate(i) then
			return i
		end
	end
	return nil
end

function InventoryManager:getNext(delegate, last)
	last = last or 0
	for i = last + 1, 16 do
		if delegate(i) then
			return i
		end
	end
	return nil
end

function InventoryManager:getAll(delegate)
	local r = {}
	for i in function(...)
		return self:getNext(...)
	end, delegate do
		table.insert(r, i)
	end
	return r
end

function InventoryManager:getFirstContaining(selector) --GOOD
	return self:getFirst(self._delContaining(selector))
end

function InventoryManager:getNextContaining(selector, last) --GOOD
	return self:getNext(self._delContaining(selector), last)
end

--[[
	Returns a list of slots that contain items matching the selector
]]
function InventoryManager:getAllContaining(selector)
	return self:getAll(self._delContaining(selector))
end

function InventoryManager:getFirstSameAs(slot) --GOOD
	return self:getFirst(self._delSameAs)
end

function InventoryManager:getNextSameAs(slot, index) --GOOD
	return self:getNext(self._delSameAs, index)
end

function InventoryManager:getAllSameAs(slot) --GOOD
	return self:getAll(self._delSameAs)
end

function InventoryManager:getFirstEmpty() --GOOD
	return self:getFirst(self._delEmpty)
end

function InventoryManager:getNextEmpty(last) --GOOD
	return self:getNext(self._delEmpty, last)
end

function InventoryManager:getAllEmpty() --GOOD
	return self:getAll(self._delEmpty)
end

function InventoryManager:getLastEmpty() --GOOD
	return self:getLast(self._delEmpty)
end

Inv = InventoryManager(turtle)
