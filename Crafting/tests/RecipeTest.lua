test(
	'Recipe',
	{
		['Item Count'] = function(t)
			local obj = Recipe.new('item1', {'item2', 'item3', 'item3'}, 1)

			t.assertEqual(obj.itemCount, 3)
		end,
		['Specific Item Count'] = function(t)
			local obj = Recipe.new('item1', {'item2', 'item3', 'item3'}, 1)

			t.assertEqual(obj.items['item2'], 1)
			t.assertEqual(obj.items['item3'], 2)
		end
	}
)
