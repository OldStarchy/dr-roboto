test(
	'RecipeBook',
	{
		['crafting find by grid'] = function(t)
			local book = RecipeBook()

			local recipe = CraftingRecipe('something', {'inputA', nil, nil, 'inputB'}, 1)

			book:add(recipe)
			t.assertEqual(book:findByGrid(recipe.grid), recipe)
		end,
		['crafting find by name'] = function(t)
			local book = RecipeBook()

			local recipe = CraftingRecipe('something', {}, 1)

			book:add(recipe)
			t.assertTableEqual(book:findCraftingRecipesBySelector(recipe.name), {recipe})
		end,
		['crafting duplicate recipe'] = function(t)
			local book = RecipeBook()

			local recipe1 = CraftingRecipe('something', {'inputA', nil, nil, 'inputB'}, 1)
			local recipe2 = CraftingRecipe('anotherthing', {'inputA', nil, nil, 'inputB'}, 1)

			t.assertEqual(book:add(recipe1), true)
			t.assertEqual(book:add(recipe2), false)
			t.assertTableEqual(book:findCraftingRecipesBySelector('anotherthing'), {})
		end,
		['crafting find on empty'] = function(t)
			local book = RecipeBook()

			t.assertTableEqual(book:findCraftingRecipesBySelector('item1'), {})
		end,
		['crafting find with match'] = function(t)
			local book = RecipeBook()

			local recipe = CraftingRecipe('item1', {}, 1)
			book:add(recipe)

			t.assertTableEqual(book:findCraftingRecipesBySelector('item1'), {recipe})
		end,
		['crafting find without match'] = function(t)
			local book = RecipeBook()

			local recipe = CraftingRecipe('item1', {}, 1)
			book:add(recipe)

			t.assertTableEqual(book:findCraftingRecipesBySelector('potatoes'), {})
		end,
		['smelting find by name'] = function(t)
			local book = RecipeBook()

			local recipe = FurnaceRecipe('iron bars', 'iron ore', 4, 16)

			book:add(recipe)
			t.assertTableEqual(book:findFurnaceRecipeBySelector(recipe.name), recipe)
		end,
		['smelting duplicate recipe'] = function(t)
			local book = RecipeBook()

			local recipe1 = FurnaceRecipe('iron bars', 'iron ore', 4, 16)
			local recipe2 = FurnaceRecipe('iron barz', 'iron ore', 4, 16)

			t.assertEqual(book:add(recipe1), true)
			t.assertEqual(book:add(recipe2), false)
			t.assertEqual(book:findFurnaceRecipeBySelector('iron barz'), nil)
		end,
		['smelting find on empty'] = function(t)
			local book = RecipeBook()

			t.assertEqual(book:findFurnaceRecipeBySelector('item1'), nil)
		end,
		['smelting find with match'] = function(t)
			local book = RecipeBook()

			local recipe = FurnaceRecipe('iron_bars', 'iron_ore', 4, 16)
			book:add(recipe)

			t.assertEqual(book:findFurnaceRecipeBySelector('iron_bars'), recipe)
		end,
		['smelting find without match'] = function(t)
			local book = RecipeBook()

			local recipe = FurnaceRecipe('iron bars', 'iron ore', 4, 16)
			book:add(recipe)

			t.assertEqual(book:findFurnaceRecipeBySelector('potatoes'), nil)
		end
	}
)
