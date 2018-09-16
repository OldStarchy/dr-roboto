standardRecipes = RecipeBook()

standardRecipes:add(Recipe('plank', {'log'}, 4))
standardRecipes:add(Recipe('stick', {'plank', nil, nil, 'plank'}, 4))
standardRecipes:add(Recipe('torch', {'coal', nil, nil, 'stick'}, 4))

--charcoal burns for 80 seconds, it can create 8 cobble stone
furnaceRecipeBook = RecipeBook()

furnaceRecipeBook:add(FurnaceRecipe('stone', 'cobblestone', 1, 10))
furnaceRecipeBook:add(FurnaceRecipe('charcoal', 'log', 1, 10))
