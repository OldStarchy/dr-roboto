RecipeBook = Class()

function RecipeBook:constructor()
	self._recipes = {}
end

function RecipeBook:add(recipe)
	if (recipe.getType() ~= Recipe) then
		error('Attempt to add a non recipe to a book', 2)
	end

	if (self:findByGrid(recipe.grid) ~= nil) then
		return false
	end

	table.insert(self._recipes, recipe)
	return true
end

function RecipeBook:findByName(name)
	local recipes = {}

	for i = 1, #self._recipes do
		if (self._recipes[i].name == name) then
			table.insert(recipes, self._recipes[i])
		end
	end

	return recipes
end

function RecipeBook:findByGrid(recipe)
	for i = 1, #self._recipes do
		local match = true
		for j = 1, 9 do
			if (self._recipes[i].grid[j] ~= recipe[j]) then
				match = false
				break
			end
		end

		if (match) then
			return self._recipes[i]
		end
	end

	return nil
end
