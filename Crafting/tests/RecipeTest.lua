test(
	'Recipe',
	{
		Constructor = {
			['Dummy'] = function(t)
				local obj = Recipe.new('dummy', {'uniuqeingredient'}, 1)

				--TODO: this should throw, since the recipe {'log'} is taken by planks
			end,
			['Correct Item Count'] = function(t)
				local obj = Recipe.new('stick', {'plank', nil, nil, 'plank'}, 4)

				t.assertEqual(obj.itemCount, 2)
			end,
			['Correct Items Required'] = function(t)
				local obj = Recipe.new('stick', {'plank', nil, nil, 'plank', 'log'}, 4)
				t.assertTableEqual(obj.items, {['plank'] = 2, ['log'] = 1})
			end
		}

		--TODO: more tests
	}
)
