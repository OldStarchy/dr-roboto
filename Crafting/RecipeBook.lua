RecipeBook = Class()

function RecipeBook:constructor()
	self.recipes = {}
end

function RecipeBook:add(recipe)
	if (recipe.getType() ~= Recipe) then
		error('Attempt to add a non recipe to a book', 2)
	end

	--TODO: Check recipe isn't already defined to make something else

	table.insert(self.recipes, recipe)
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
