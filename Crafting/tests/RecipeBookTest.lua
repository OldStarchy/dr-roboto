test(
	'RecipeBook',
	{
		['find'] = function(t)
			local book = RecipeBook.new()

			local matches = book:findByName('item1')

			t.assertEqual(type(matches), 'table')
		end,
		['find on empty'] = function(t)
			local book = RecipeBook.new()

			local matches = book:findByName('item1')

			t.assertEqual(#matches, 0)
		end,
		['find with match'] = function(t)
			local book = RecipeBook.new()

			local recipe = Recipe.new('item1', {}, 1)
			book:add(recipe)

			local matches = book:findByName('item1')

			t.assertEqual(#matches, 1)
			t.assertEqual(matches[1], recipe)
		end,
		['find without match'] = function(t)
			local book = RecipeBook.new()

			local recipe = Recipe.new('item1', {}, 1)
			book:add(recipe)

			local matches = book:findByName('potatoes')

			t.assertEqual(#matches, 0)
		end
	}
)
