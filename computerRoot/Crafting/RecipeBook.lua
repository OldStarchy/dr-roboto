RecipeBook = Class()
RecipeBook.ClassName = 'RecipeBook'

function RecipeBook:constructor()
	self._craftingRecipes = {}
	self._furnaceRecipes = {}

	self.ev = EventManager()
end

function RecipeBook:serialize()
	local data = {
		crafting = {},
		smelting = {}
	}

	for _, v in ipairs(self._craftingRecipes) do
		table.insert(data.crafting, v)
	end

	for _, v in ipairs(self._furnaceRecipes) do
		table.insert(data.smelting, v)
	end

	return data
end

function RecipeBook.Deserialize(data)
	local book = RecipeBook()

	for _, v in ipairs(data.crafting) do
		table.insert(book._craftingRecipes, v)
	end

	for _, v in ipairs(data.smelting) do
		table.insert(book._furnaceRecipes, v)
	end

	return book
end

function RecipeBook:add(recipe)
	assertType(recipe, Recipe, 'Attempt to add a non recipe to a book', 2)

	local rt = recipe:getType()

	--TODO: CraftingRecipe should be base of CraftingRecipe and FurnaceRecipe
	if (isType(rt, CraftingRecipe)) then
		if (self:findByGrid(recipe.grid) ~= nil) then
			return false
		end

		-- Doesn't work if loaded from a hardtable
		table.insert(self._craftingRecipes, recipe)
	elseif (isType(rt, FurnaceRecipe)) then
		if (self:findByIngredient(recipe.ingredient) ~= nil) then
			return false
		end

		table.insert(self._furnaceRecipes, recipe)
	else
		error('unknown recipe type', 2)
	end

	self.ev:trigger('state_changed')

	return true
end

function RecipeBook:findCraftingRecipesBySelector(selector)
	local recipes = {}

	for i = 1, #self._craftingRecipes do
		local resultDetail = ItemDetail.FromId(self._craftingRecipes[i].name)

		if (resultDetail:matches(selector)) then
			table.insert(recipes, self._craftingRecipes[i])
		end
	end

	return recipes
end

function RecipeBook:findBestCraftingRecipeBySelector(selector)
	local recipes = self:findCraftingRecipesBySelector(selector)
	if #recipes == 0 then
		return nil
	end

	local bestRecipe = nil
	local bestRecipeCount = 9999999

	for k, recipe in ipairs(recipes) do
		local itemsNeeded = 0

		for item, count in pairs(recipe.items) do
			local haveCount = inv:countItem(item)
			itemsNeeded = itemsNeeded + count - haveCount
		end

		if (itemsNeeded < bestRecipeCount) then
			bestRecipe = recipe
			bestRecipeCount = itemsNeeded
		end
	end

	return bestRecipe
end

function RecipeBook:findFurnaceRecipeBySelector(selector)
	for i = 1, #self._furnaceRecipes do
		local resultDetail = ItemDetail.FromId(self._furnaceRecipes[i].name)

		if (resultDetail:matches(selector)) then
			return self._furnaceRecipes[i]
		end
	end

	return nil
end

function RecipeBook:findByIngredient(ingredient)
	for i = 1, #self._furnaceRecipes do
		local resultDetail = ItemDetail.FromId(self._furnaceRecipes[i].ingredient)

		if (resultDetail:matches(ingredient)) then
			return self._furnaceRecipes[i]
		end
	end

	return nil
end

function RecipeBook:findByGrid(recipe)
	for i = 1, #self._craftingRecipes do
		local match = true
		for j = 1, 9 do
			local item = self._craftingRecipes[i].grid[j]
			if item == nil then
				if (recipe[j] ~= nil) then
					match = false
					break
				end
			elseif (recipe[j] == nil) then
				match = false
				break
			else
				local resultDetail = ItemDetail.FromId(item)

				if (not resultDetail:matches(recipe[j])) then
					match = false
					break
				end
			end
		end

		if (match) then
			return self._craftingRecipes[i]
		end
	end

	return nil
end
