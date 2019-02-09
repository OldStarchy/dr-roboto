test(
	'Furnace',
	{
		Constructor = {
			['Goto Top'] = function(t)
				local location = Position(5, 5, 5, Position.SOUTH)
				local obj = Furnace('furnace', location)

				print(obj:toString())
				obj:navigateTo()
				t.assertEqual(nav:getX(), 5)
				t.assertEqual(nav:getY(), 5)
				t.assertEqual(nav:getZ(), 4)

				obj:gotoTop()
			end
		}
	}
)
