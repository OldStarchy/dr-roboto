test(
	'Furnace',
	{
		Constructor = {
			['Goto Top'] = function(t)
				local location = Position(5, 5, 5, Position.SOUTH)
				local obj = Furnace(location)

				obj:navigateTo()
				t.assertEqual(Nav:getX(), 5)
				t.assertEqual(Nav:getY(), 5)
				t.assertEqual(Nav:getZ(), 4)

				obj:gotoTop()
			end
		}
	}
)
