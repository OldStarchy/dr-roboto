test(
	'Recipe',
	{
		Constructor = function(t)
			local obj = Recipe.new('dummy', {'uniuqeingredient'}, 1)

			--TODO: this should throw, since the recipe {'log'} is taken by planks
		end

		--TODO: more tests
	}
)
