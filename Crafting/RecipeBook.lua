RecipeBook = Class()

function RecipeBook:constructor()
	self.recipes = {}
end

function RecipeBook:add(recipe)
	if (recipe.getType() ~= Recipe) then
		error('Attempt to add a non recipe to a book', 2)
	end

	--TODO: Check recipe isn't already defined to make something else

	if (self:findByGrid(recipe.grid) ~= nil) then
		return false
	end

	table.insert(self.recipes, recipe)
	return true
end

function RecipeBook:findByName(name)
	local recipes = {}

	for i = 1, #self.recipes do
		if (self.recipes[i].name == name) then
			table.insert(recipes, self.recipes[i])
		end
	end

	return recipes
end

function RecipeBook:findByGrid(recipe)
	for i = 1, #self.recipes do
		local match = true
		for j = 1, 9 do
			if (self.recipes[i].grid[j] ~= recipe[j]) then
				match = false
				break
			end
		end

		if (match) then
			return self.recipes[i]
		end
	end

	return nil
end
