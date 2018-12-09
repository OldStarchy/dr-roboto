test(
	'FurnaceRecipe',
	{
		['Constructor'] = function(t)
			local obj = FurnaceRecipe('iron bars', 'iron ore', 4, 16)

			t.assertEqual(obj.name, 'iron bars')
			t.assertEqual(obj.ingredient, 'iron ore')
			t.assertEqual(obj.produces, 4)
			t.assertEqual(obj.burnTime, 16)
		end
	}
)
