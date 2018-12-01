RecipeBook = Class()
RecipeBook.ClassName = 'RecipeBook'

function RecipeBook:constructor()
	self._craftingRecipes = {}
	self._furnaceRecipes = {}
end

function RecipeBook:add(recipe)
	assertType(recipe, Recipe, 'Attempt to add a non recipe to a book', 2)

	local rt = recipe:getType()

	--TODO: Recipe should be base of CraftingRecipe and FurnaceRecipe
	if (rt == Recipe) then
		if (self:findByGrid(recipe.grid) ~= nil) then
			return false
		end
	elseif (isType(rt, FurnaceRecipe)) then
		if (self:findByIngredient(recipe.ingredient) ~= nil) then
			return false
		end
	else
		error('unknown recipe type', 2)
	end

	table.insert(self._craftingRecipes, recipe)
	return true
end

function RecipeBook:findCraftingRecipeByName(name)
	for i = 1, #self._craftingRecipes do
		print(self._craftingRecipes[i].name, name)
		if (self._craftingRecipes[i].name == name) then
			return self._craftingRecipes[i]
		end
	end
end

function RecipeBook:findFurnaceRecipeByName(name)
	for i = 1, #self.furnaceRecipes do
		if (self.furnaceRecipes[i].name == name) then
			return self.furnaceRecipes[i]
		end
	end
end

function RecipeBook:findByIngredient(ingredient)
	for i = 1, #self._furnaceRecipes do
		if (self._furnaceRecipes[i].ingredient ~= ingredient) then
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
