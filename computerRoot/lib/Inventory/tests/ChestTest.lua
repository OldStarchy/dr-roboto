test(
	'Chest',
	{
		Constructor = {
			['Single Chest Constructor'] = function(t)
				local p = Position(5, 5, 5, Position.SOUTH)

				local chest = Chest(p, false)
				t.assertEqual(chest:inventory():size(), 27)

				local chest2 = Chest(p, true)
				t.assertEqual(chest2:inventory():size(), 54)
			end
		}
	}
)
