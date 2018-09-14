-- TODO: potential name change to Artisan
Crafter = Class()

function Crafter:constructor(turtle)
	self._book = RecipeBook.new()

	self._turtle = turtle
end

function Crafter:setRecipeBook(recipeBook)
	if (recipeBook == nil) then
		self._book = RecipeBook.new()
	end

	if (recipeBook.getType() ~= RecipeBook) then
		error('Setting a non-book as the crafting recipe book')
	end

	self._book = recipeBook
end

function Crafter:getRawItems(itemName, amount)
	if (type(amount) ~= 'number' or amount < 0) then
		error('Invalid amount ' .. tostring(amount) .. ' for crafting', 2)
	end

	if (amount == 0) then
		return {}
	end

	local recipe = self._book:findByName(itemName)

	if (recipe == nil) then
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

	for item, count in pairs(recipe.items) do
		local rawItems = Crafter.getRawItems(i)

		for item2, count2 in pairs(rawItems) do
			coreRequirements[item2] = coreRequirements[item2] + count2 * amount
		end
	end

	return coreRequirements
end

function Crafter:craft(item, amount)
	local graph = Crafter.buildCraftGraph(item, amount)

	Crafter.craftFromGraph(graph)
end

function Crafter:craftFromGraph(graph)
	local leafNodes = Graph.leafNodes(graph)

	local items = leafNodes.groupBy(item) --psudocode
	--foreach leaf node in items
	obtain(node.item, node.amount)
end

Crafting = Crafter.new(turtle)
