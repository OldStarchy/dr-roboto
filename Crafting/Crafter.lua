-- TODO: potential name change to Artisan
Crafter = Class()

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

function Crafter:getRawItems(itemName, amount)
	if (type(itemName) ~= 'string') then
		error('itemName must be string', 2)
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

	local recipes = self._book:findByName(itemName)

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
		local rawItems = self:getRawItems(item)

		for item2, count2 in pairs(rawItems) do
			coreRequirements[item2] = coreRequirements[item2] + count2 * amount
		end
	end

	return coreRequirements
end

function Crafter:craft(item, amount)
	local graph = self:buildCraftGraph(item, amount)

	self:craftFromGraph(graph)
end

function Crafter:craftFromGraph(graph)
	local leafNodes = Graph.leafNodes(graph)

	local items = leafNodes.groupBy(item) --psudocode
	--foreach leaf node in items
	obtain(node.item, node.amount)
end

Crafting = Crafter(turtle)
