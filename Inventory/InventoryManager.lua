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
		item = turtle.getItemDetail(item)
	end

	if (item == nil) then
		return false
	end

	if (selector == '*') then
		return true
	end

	local name = item.name .. ':' .. item.damage
	print(name)

	local subSelectors = {}
	for subSelector in selector:gmatch('[^,]*') do
		local colons = select(2, subSelector:gsub(':', ''))
		if (colons == 0) then
			subSelector = '*:' .. subSelector .. ':*'
		elseif (colons == 1) then
			subSelector = '*:' .. subSelector
		end
		subSelector = string.gsub(subSelector, '([%(%)%.%%%+%-%?%[%^%$%]])', '%%%1')
		subSelector = string.gsub(subSelector, '%*', '[^:]*')
		table.insert(subSelectors, subSelector)
	end

	for _, subSelector in pairs(subSelectors) do
		if (name:match(subSelector)) then
			return true
		end
	end
	return false
end
function InventoryManager:constructor(turtle)
	self._turtle = turtle
	self._oldTurtle = turtle
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

	print('what')
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
