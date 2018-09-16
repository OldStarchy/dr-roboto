Furnace = Class(Block)

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Furnace:constructor(name, location)
	Block:constructor(name, location)
	self._book = RecipeBook()

	self._top = nil
	self._output = nil
	self._bottom = nil

	self._pos = 'front'
end

function Furnace:setRecipeBook(recipeBook)
	if (recipeBook == nil) then
		self._book = RecipeBook()
	end

	if (recipeBook.getType() ~= RecipeBook) then
		error('Setting a non-book as the crafting recipe book')
	end

	self._book = recipeBook
end

function Furnace:gotoBottom()
	if (self._pos == 'bottom') then
		return true
	end
	if (self._pos == 'front') then
		if (Nav:down() and Nav:forward()) then
			self._pos = 'bottom'
			return true
		else
			self._pos = 'unknown'
			return false
		end
	elseif (self._pos == 'top') then
		return self:gotoFront() and self:gotoBottom()
	end
	return false
end
function Furnace:gotoTop()
	if (self._pos == 'top') then
		return true
	end
	if (self._pos == 'front') then
		if (Nav:up() and Nav:forward()) then
			self._pos = 'top'
			return true
		else
			self._pos = 'unknown'
			return false
		end
	elseif (self._pos == 'bottom') then
		return self:gotoFront() and self:gotoTop()
	end
	return false
end
function Furnace:gotoFront()
	if (self._pos == 'front') then
		return true
	end
	if (self._pos == 'top') then
		if (Nav:back() and Nav:down()) then
			self._pos = 'front'
			return true
		else
			self._pos = 'unknown'
			return false
		end
	elseif (self._pos == 'bottom') then
		if (Nav:back() and Nav:up()) then
			self._pos = 'front'
			return true
		else
			self._pos = 'unknown'
			return false
		end
	end
	return false
end

--TODO: Face the furnace.
--Puts one item in the top, and one in the bottom of a furnace
--then waits 12 seconds for it to cook, and takes the item out
function Furnace:smelt(furnaceRecipe, quantity, fuel)
	if furnaceRecipe.getType() ~= FurnaceRecipe then
		return error('Can not smelt object that is not a furnace recipe')
	end
	print('smelting ' .. furnaceRecipe.name)

	self:gotoTop()
	Inv:select(furnaceRecipe.ingredient)
	Inv:dropDown(1)
	self:gotoFront()
	Inv:select(fuel)
	Inv:drop()

	local burnTime = furnaceRecipe.burnTime * quantity

	local timerId = os.startTimer(burnTime)
	local timers = {}
	for i = 1, (burnTime - 1) do
		timers[os.startTimer(i)] = i
	end
	self:gotoBottom()

	while true do
		local event, id = os.pullEvent('timer')
		if id == timerId then
			break
		end
		if (timers[id]) then
			print(burnTime - timers[id])
		end
	end

	Inv:suckUp()
end
