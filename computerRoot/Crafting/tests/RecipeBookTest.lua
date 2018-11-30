test(
	'RecipeBook',
	{
		['find'] = function(t)
			local book = RecipeBook()

			local matches = book:findCraftingRecipeByName('item1')

			t.assertEqual(type(matches), 'table')
		end,
		['duplicate recipe'] = function(t)
			local book = RecipeBook()

			local recipe1 = Recipe('something', {'inputA', nil, nil, 'inputB'}, 1)
			local recipe2 = Recipe('anotherthing', {'inputA', nil, nil, 'inputB'}, 1)

			t.assertEqual(book:add(recipe1), true)
			t.assertEqual(book:add(recipe2), false)

			t.assertEqual(#book:findCraftingRecipeByName('anotherthing'), 0)
		end,
		['find on empty'] = function(t)
			local book = RecipeBook()

			local matches = book:findCraftingRecipeByName('item1')

			t.assertEqual(#matches, 0)
		end,
		['find with match'] = function(t)
			local book = RecipeBook()

			local recipe = Recipe('item1', {}, 1)
			book:add(recipe)

			local matches = book:findCraftingRecipeByName('item1')

			t.assertEqual(#matches, 1)
			t.assertEqual(matches[1], recipe)
		end,
		['find without match'] = function(t)
			local book = RecipeBook()

			local recipe = Recipe('item1', {}, 1)
			book:add(recipe)

			local matches = book:findCraftingRecipeByName('potatoes')

			t.assertEqual(#matches, 0)
		end
	}
)
