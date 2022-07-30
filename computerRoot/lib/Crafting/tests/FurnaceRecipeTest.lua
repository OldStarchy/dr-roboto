test(
	'FurnaceRecipe',
	{
		['Constructor'] = function(t)
			local obj = FurnaceRecipe('iron_bars', 'iron_ore', 4, 16)

			t.assertEqual(obj.output, '*:iron_bars:*')
			t.assertEqual(obj.ingredient, '*:iron_ore:*')
			t.assertEqual(obj.outputCount, 4)
			t.assertEqual(obj.burnTime, 16)
		end
	}
)
