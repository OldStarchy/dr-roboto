standardRecipes = RecipeBook.new()

standardRecipes:add(Recipe.new('plank', {'log'}, 4))
standardRecipes:add(Recipe.new('stick', {'plank', nil, nil, 'plank'}, 4))
standardRecipes:add(Recipe.new('torch', {'coal', nil, nil, 'stick'}, 4))
