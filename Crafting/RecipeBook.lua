local RecipeBook = Class()

function RecipeBook:constructor()
	self.recipes = {}
end

function RecipeBook:add(recipe)
	--TODO: Check arg is actually a recipe

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

return RecipeBook
