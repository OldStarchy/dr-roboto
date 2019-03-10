-- TODO: potential name change to Artisan
Crafter = Class()
Crafter.ClassName = 'Crafter'

function Crafter:constructor(turtle)
	self._book = RecipeBook()

	self._turtle = turtle
end

function Crafter:setRecipeBook(recipeBook)
	if (recipeBook == nil) then
		self._book = RecipeBook()
	end

	if (recipeBook.getType() ~= RecipeBook) then
		error('Setting a non-book as the crafting recipe book')
	end

	self._book = recipeBook
end

function Crafter:getRawItems(itemName, amount, checked)
	if (type(itemName) ~= 'string') then
		error('itemName must be string', 2)
	end

	if (checked == nil) then
		checked = {}
	end

	if (checked[itemName] == true) then
		-- Probably erroring isn't correct, since we can't tell if its a recursive error, or multiple items in a recipe need to craft this
		error('Rechecking an item')
	end

	if (amount == nil) then
		amount = 1
	end

	if (type(amount) ~= 'number' or amount < 0) then
		error('Invalid amount ' .. tostring(amount) .. ' for crafting', 2)
	end

	if (amount == 0) then
		return {}
	end

	checked[itemName] = true

	local recipes = self._book:findCraftingRecipesBySelector(itemName)

	if (#recipes == 0) then
		return {[itemName] = amount}
	end

	local coreRequirements =
		setmetatable(
		{},
		{
			__index = function()
				return 0
			end
		}
	)

	-- Assume first recipe is best
	-- TODO: don't assume this
	local recipe = recipes[1]

	for item, count in pairs(recipe.items) do
		local rawItems = self:getRawItems(item, count * amount, checked)

		for item2, count2 in pairs(rawItems) do
			coreRequirements[item2] = coreRequirements[item2] + count2 * amount
		end
	end

	return coreRequirements
end

function Crafter:_hasIngredientsToCraft(recipe, amount)
	local items = cloneTable(recipe.items)

	local err = false
	for _item, count in pairs(items) do
		log.info('need "' .. _item .. '" * ' .. tostring(count * amount))
		local _count = inv:getUnlockedCount(_item)
		log.info('have ' .. tostring(_count))
		if (_count < count * amount) then
			err = true
			log.info('missing ' .. tostring((count * amount) - _count) .. ' ' .. _item)
		end
	end

	return not err
end

function Crafter:craft(item, amount)
	if (turtle.craft == nil) then
		if (inv:pushSelection('crafting_table')) then
			turtle.equipLeft()
			inv:popSelection()
		end
		if (turtle.craft == nil) then
			error('Missing crafting bench!')
		end
	end

	local recipe = nil

	amount = assertType(coalesce(amount, 1), 'int')

	if (type(item) == 'string') then
		local recipes = RecipeBook.Instance:findCraftingRecipesBySelector(item)

		if (#recipes == 0) then
			error('no recipe for ' .. item)
		end

		for _, v in ipairs(recipes) do
			if (self:_hasIngredientsToCraft(v, amount)) then
				recipe = v
				break
			end
		end
	elseif (isType(item, Recipe)) then
		recipe = item
	else
		error('item must be string or Recipe', 2)
	end

	if (recipe == nil) then
		error('not enough resources to craft ' .. item)
	end

	log.info('Trying to craft ' .. recipe.output .. ' ' .. tostring(amount) .. ' times')

	local _, belowBlock = turtle.inspectDown()
	if (inv:select('chest')) then
		if (belowBlock) then
			log.warn('digging down')
			turtle.digDown()
		end
		if (not turtle.placeDown()) then
			error('Could not place chest')
		end
	else
		error('No crafting Chest')
	end

	local items = cloneTable(recipe.items)

	for i, v in pairs(items) do
		local stackSize = ItemInfo.Instance:getStackSize(i)
		if (stackSize < amount * v) then
			error('cant craft that many at once')
		end
		items[i] = amount * v
	end

	for i = 1, 16 do
		local itemStack = inv:getItemDetail(i)

		local dump = true
		for _item, _amount in pairs(items) do
			if (itemStack == nil) then
				dump = false
			elseif (itemStack:matches(_item)) then
				if (itemStack.count >= _amount) then
					items[_item] = nil

					turtle.select(i)
					turtle.dropDown(itemStack.count - _amount)
				else
					items[_item] = items[_item] - itemStack.count
				end
				dump = false
				break
			end
		end

		if (dump) then
			turtle.select(i)
			turtle.dropDown()
		end
	end

	for i = 1, 9 do
		if (recipe.grid[i] ~= nil) then
			if (not inv:lock(i + math.floor((i - 1) / 3), recipe.grid[i], amount)) then
				error('failed to set up crafting recipe')
			end
		end
	end

	turtle.craft(amount)
	inv:unlockAll()

	while (turtle.suckDown()) do
	end
	turtle.digDown()

	if (belowBlock) then
		--Try to put the exact same block back down, but fallback to just the name for blocks whos id changes depending on their direction
		if (inv:select(belowBlock:getId()) or inv:select(belowBlock.name) or inv:select('dirt,cobblestone')) then
			turtle.placeDown()
		end
	end

	return true
end

function Crafter:craftFromGraph(graph)
	local leafNodes = Graph.leafNodes(graph)

	local items = leafNodes.groupBy(item) --psudocode
	--foreach leaf node in items
	obtain(node.item, node.amount)
end
