Furnace = Class(Block)
Furnace.ClassName = 'Furnace'

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Furnace:constructor(location)
	Block.constructor(self, location)

	self._top = ItemStore(1)
	self._side = ItemStore(1)
	self._bottom = ItemStore(1)

	self._currentFuel = nil

	self._burnStartTime = nil
	self._burnTimer = nil

	self._smeltStartTime = nil
	self._smeltTimer = nil

	self.ev = EventManager()

	self.ev:on(
		'block_destroyed',
		function()
			if (self._burnTimer ~= nil) then
				self._burnTimer.cancel()
				self._burnTimer = nil
			end

			if (self._smeltTimer ~= nil) then
				self._smeltTimer.cancel()
				self._smeltTimer = nil
			end
		end
	)
end

--Doesn't trigger events, functions that call this method should do so
function Furnace:_checkSmelt()
	local top = self._top:peek()
	local bottom = self._bottom:peek()

	if (top == nil) then
		self._smeltStartTime = nil
		return
	end

	local recipe = RecipeBook.Instance:findByIngredient(top)

	if (recipe == nil) then
		self._smeltStartTime = nil
		return
	end

	if (self._currentFuel == nil) then
		if (bottom ~= nil) then
			self:_consumeFuel()
			self._smeltStartTime = os.time()

			self._smeltTimer =
				os.sleepAsync(
				12,
				function()
					self._smeltStartTime = nil
					self._smeltTimer = nil
					self:_checkSmelt()
				end
			)
		else
			if (self._smeltTimer ~= nil) then
				self._smeltStartTime = nil
				self._smeltTimer.cancel()
				self._smeltTimer = nil
			end
			return
		end
	end
end

--Doesn't trigger events, functions that call this method should do so
function Furnace:_consumeFuel()
	local bottom = self._bottom:pop()

	if (bottom == nil) then
		error('Cant consume fuel when there is none', 4)
	end

	local burnTime = ItemInfo.Instance:getBurnTime(bottom)

	if (burnTime == nil) then
		error(bottom:getId() ' is not a valid fuel', 4)
	end

	self._currentFuel = bottom:getId()
	self._burnStartTime = os.time()

	self._burnTimer =
		os.sleepAsync(
		burnTime,
		function()
			self._currentFuel = nil
			self._burnStartTime = nil
			self:_checkSmelt()
		end
	)

	if (bottom:matches('lava_bucket')) then
		self._bottom:push(ItemStackDetail('bucket'))
	else
		bottom.count = bottom.count - 1

		if (bottom.count == 0) then
			self._bottom:push(bottom)
		end
	end
end

function Furnace:pushTop(itemStack)
	self._top:push(itemStack)

	self:_checkSmelt()

	self.ev:trigger('change_state')
end

function Furnace:popTop()
	local stack = self._top:pop()

	if (stack ~= nil) then
		self:_checkSmelt()
		self.ev:trigger('change_state')
	end

	return stack
end

function Furnace:pushBottom(itemStack)
	self._bottom:push(itemStack)

	self:_checkSmelt()

	self.ev:trigger('change_state')
end

function Furnace:popBottom()
	local stack = self._bottom:pop()

	if (stack ~= nil) then
		self:_checkSmelt()
		self.ev:trigger('change_state')
	end

	return stack
end

function Furnace:popSide()
	local stack = self._side:pop()

	if (stack ~= nil) then
		self:_checkSmelt()
		self.ev:trigger('change_state')
	end

	return stack
end

--move to nav
--[[
function Furnace:gotoBottom()
	if (self._pos == 'bottom') then
		return true
	end
	if (self._pos == 'front') then
		if (mov:down() and mov:forward()) then
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
		if (mov:up() and mov:forward()) then
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
		if (mov:back() and mov:down()) then
			self._pos = 'front'
			return true
		else
			self._pos = 'unknown'
			return false
		end
	elseif (self._pos == 'bottom') then
		if (mov:back() and mov:up()) then
			self._pos = 'front'
			return true
		else
			self._pos = 'unknown'
			return false
		end
	end
	return false
end
]]
--TODO: Face the furnace.
--Puts one item in the top, and one in the bottom of a furnace
--then waits 12 seconds for it to cook, and takes the item out
function Furnace:smelt(furnaceRecipe, quantity, fuel)
	if furnaceRecipe.getType() ~= FurnaceRecipe then
		return error('Can not smelt object that is not a furnace recipe')
	end
	print('smelting ' .. furnaceRecipe.output)

	self:gotoTop()
	inv:select(furnaceRecipe.ingredient)
	inv:dropDown(1)
	self:gotoFront()
	inv:select(fuel)
	inv:drop()

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

	inv:suckUp()
end
