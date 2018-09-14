test(
	'RecipeBook',
	{
		['find'] = function(t)
			local book = RecipeBook.new()

			local matches = book:findByName('item1')

			t.assertEqual(type(matches), 'table')
		end,
		['duplicate recipe'] = function(t)
			local book = RecipeBook.new()

			local recipe1 = Recipe.new('something', {'inputA', nil, nil, 'inputB'}, 1)
			local recipe2 = Recipe.new('anotherthing', {'inputA', nil, nil, 'inputB'}, 1)

			t.assertEqual(book:add(recipe1), true)
			t.assertEqual(book:add(recipe2), false)

			t.assertEqual(book:findByName(anotherthing), nil)
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
