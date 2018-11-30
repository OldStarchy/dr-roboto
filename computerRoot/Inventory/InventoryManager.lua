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

function InventoryManager:constructor(turtle)
	self._turtle = turtle
	self._oldTurtle = {}

	self._locked = {}
	self._selectionStack = {}
	self:_attach()
end

function InventoryManager:_attach()
	local this = self
	local overrideFunctionsList = {
		'inspect',
		'getItemDetail',
		'select'
	}

	for _, func in ipairs(overrideFunctionsList) do
		self._oldTurtle[func] = self._turtle[func]
		self._turtle[func] = function(...)
			return this[func](this, unpack({...}))
		end
	end
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

	return ItemStackDetail.convertToInstance(data)
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

Inv = InventoryManager(turtle)
