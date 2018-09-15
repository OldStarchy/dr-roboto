Furnace = Class()

function Furnace:constructor(location)
	self._book = RecipeBook()

	self.location = location

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

function Furnace:smelt(item, fuel)
	print('smelting ' .. item)
	self:gotoTop()
	Inv:select(item)
	Inv:dropDown(1)
	self:gotoFront()
	Inv:select(fuel)
	Inv:drop()
	local timerId = os.startTimer(12)
	local timers = {}
	for i = 1, 11 do
		timers[os.startTimer(i)] = i
	end
	self:gotoBottom()

	while true do
		local event, id = os.pullEvent('timer')
		if id == timerId then
			break
		end
		if (timers[id]) then
			print(12 - timers[id])
		end
	end

	Inv:suckUp()
end
