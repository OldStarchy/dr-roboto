standardRecipes = RecipeBook()

standardRecipes:add(Recipe('plank', {'log'}, 4))
standardRecipes:add(Recipe('stick', {'plank', nil, nil, 'plank'}, 4))
standardRecipes:add(Recipe('torch', {'coal', nil, nil, 'stick'}, 4))
