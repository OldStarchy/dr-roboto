RecipeBook = Class()
RecipeBook.ClassName = 'RecipeBook'

function RecipeBook:constructor()
	self._craftingRecipes = {}
	self._furnaceRecipes = {}

	self._saveToFilename = nil
end

function RecipeBook:serialize()
	local data = {
		crafting = {},
		smelting = {}
	}

	for _, v in ipairs(self._craftingRecipes) do
		table.insert(data.crafting, v:serialize())
	end

	for _, v in ipairs(self._furnaceRecipes) do
		table.insert(data.smelting, v:serialize())
	end

	return data
end

function RecipeBook.Deserialize(data)
	local book = RecipeBook()

	for _, v in ipairs(data.crafting) do
		table.insert(book._craftingRecipes, CraftingRecipe.Deserialize(v))
	end

	for _, v in ipairs(data.smelting) do
		table.insert(book._furnaceRecipes, FurnaceRecipe.Deserialize(v))
	end

	return book
end

function RecipeBook:saveToFile(filename)
	assertType(filename, 'string')

	local data = self:serialize()

	print('saving to', filename)
	fs.writeTableToFile(filename, data)
end

function RecipeBook.LoadFromFile(filename, autoSave)
	assertType(filename, 'string')
	local book

	if (fs.exists(filename)) then
		local data = fs.readTableFromFile(filename)

		book = RecipeBook.Deserialize(data)
	else
		book = RecipeBook()
	end

	if (autoSave) then
		book._saveToFilename = filename
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

	if (self._saveToFilename ~= nil) then
		self:saveToFile(self._saveToFilename)
	end

	return true
end

--TODO: rename to findCraftingRecipesBySelector
function RecipeBook:findCraftingRecipeByName(selector)
	local recipes = {}

	for i = 1, #self._craftingRecipes do
		local resultDetail = ItemDetail.FromId(self._craftingRecipes[i].name)

		if (resultDetail:matches(selector)) then
			table.insert(recipes, self._craftingRecipes[i])
		end
	end

	return recipes
end

function RecipeBook:findFurnaceRecipeByName(name)
	for i = 1, #self._furnaceRecipes do
		if (self._furnaceRecipes[i].name == name) then
			return self._furnaceRecipes[i]
		end
	end

	return nil
end

function RecipeBook:findByIngredient(ingredient)
	for i = 1, #self._furnaceRecipes do
		if (self._furnaceRecipes[i].ingredient == ingredient) then
			return self._furnaceRecipes[i]
		end
	end

	return nil
end

function RecipeBook:findByGrid(recipe)
	for i = 1, #self._craftingRecipes do
		local match = true
		for j = 1, 9 do
			if (self._craftingRecipes[i].grid[j] ~= recipe[j]) then
				match = false
				break
			end
		end

		if (match) then
			return self._craftingRecipes[i]
		end
	end

	return nil
end
