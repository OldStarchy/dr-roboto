--RecipeBook.Instance = RecipeBook()

RecipeBook.Instance:add(CraftingRecipe('plank', {'log'}, 4))
RecipeBook.Instance:add(CraftingRecipe('stick', {'plank', nil, nil, 'plank'}, 4))
RecipeBook.Instance:add(CraftingRecipe('torch', {'coal', nil, nil, 'stick'}, 4))

RecipeBook.Instance:add(CraftingRecipe('glass_pane', {'glass', 'glass', 'glass', 'glass', 'glass', 'glass'}, 16))
RecipeBook.Instance:add(
	CraftingRecipe(
		'furnace',
		{
			'cobblestone',
			'cobblestone',
			'cobblestone',
			'cobblestone',
			nil,
			'cobblestone',
			'cobblestone',
			'cobblestone',
			'cobblestone'
		},
		1
	)
)

RecipeBook.Instance:add(FurnaceRecipe('glass', 'sand', 1))

--complete list:
--https://minecraft.gamepedia.com/Smelting
--lava bucket 1000
--charcoal,coal burns for 80 seconds
--log 15
--plank 15
--stick 5
--furnaceRecipeBook = RecipeBook()

--furnaceRecipeBook:add(FurnaceRecipe('stone', 'cobblestone', 1, 10))
--furnaceRecipeBook:add(FurnaceRecipe('charcoal', 'log', 1, 10))
