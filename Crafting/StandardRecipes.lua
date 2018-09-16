standardRecipes = RecipeBook()

standardRecipes:add(Recipe('plank', {'log'}, 4))
standardRecipes:add(Recipe('stick', {'plank', nil, nil, 'plank'}, 4))
standardRecipes:add(Recipe('torch', {'coal', nil, nil, 'stick'}, 4))

--complete list:
--https://minecraft.gamepedia.com/Smelting
--lava bucket 1000
--charcoal,coal burns for 80 seconds
--log 15
--plank 15
--stick 5
furnaceRecipeBook = RecipeBook()

furnaceRecipeBook:add(FurnaceRecipe('stone', 'cobblestone', 1, 10))
furnaceRecipeBook:add(FurnaceRecipe('charcoal', 'log', 1, 10))
