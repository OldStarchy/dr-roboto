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
			t.assertTableEqual(book:findCraftingRecipeByName(recipe.name), {recipe})
		end,
		['crafting duplicate recipe'] = function(t)
			local book = RecipeBook()

			local recipe1 = CraftingRecipe('something', {'inputA', nil, nil, 'inputB'}, 1)
			local recipe2 = CraftingRecipe('anotherthing', {'inputA', nil, nil, 'inputB'}, 1)

			t.assertEqual(book:add(recipe1), true)
			t.assertEqual(book:add(recipe2), false)
			t.assertTableEqual(book:findCraftingRecipeByName('anotherthing'), {})
		end,
		['crafting find on empty'] = function(t)
			local book = RecipeBook()

			t.assertTableEqual(book:findCraftingRecipeByName('item1'), {})
		end,
		['crafting find with match'] = function(t)
			local book = RecipeBook()

			local recipe = CraftingRecipe('item1', {}, 1)
			book:add(recipe)

			t.assertTableEqual(book:findCraftingRecipeByName('item1'), {recipe})
		end,
		['crafting find without match'] = function(t)
			local book = RecipeBook()

			local recipe = CraftingRecipe('item1', {}, 1)
			book:add(recipe)

			t.assertTableEqual(book:findCraftingRecipeByName('potatoes'), {})
		end,
		['smelting find by name'] = function(t)
			local book = RecipeBook()

			local recipe = FurnaceRecipe('iron bars', 'iron ore', 4, 16)

			book:add(recipe)
			t.assertTableEqual(book:findFurnaceRecipeByName(recipe.name), recipe)
		end,
		['smelting duplicate recipe'] = function(t)
			local book = RecipeBook()

			local recipe1 = FurnaceRecipe('iron bars', 'iron ore', 4, 16)
			local recipe2 = FurnaceRecipe('iron barz', 'iron ore', 4, 16)

			t.assertEqual(book:add(recipe1), true)
			t.assertEqual(book:add(recipe2), false)
			t.assertEqual(book:findFurnaceRecipeByName('iron barz'), nil)
		end,
		['smelting find on empty'] = function(t)
			local book = RecipeBook()

			t.assertEqual(book:findFurnaceRecipeByName('item1'), nil)
		end,
		['smelting find with match'] = function(t)
			local book = RecipeBook()

			local recipe = FurnaceRecipe('iron bars', 'iron ore', 4, 16)
			book:add(recipe)

			t.assertEqual(book:findFurnaceRecipeByName('iron bars'), recipe)
		end,
		['smelting find without match'] = function(t)
			local book = RecipeBook()

			local recipe = FurnaceRecipe('iron bars', 'iron ore', 4, 16)
			book:add(recipe)

			t.assertEqual(book:findFurnaceRecipeByName('potatoes'), nil)
		end
	}
)
