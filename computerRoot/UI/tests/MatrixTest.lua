test(
	'Matrix',
	{
		['Translates'] = function(t)
			local m = Matrix()
			m:translate(10, 20)

			local x, y = 0, 0
			local rx, ry = m:transformPoint(x, y)

			t.assertEqual(rx, 10)
			t.assertEqual(ry, 20)
		end,
		['Scales'] = function(t)
			local m = Matrix()
			m:scale(2, 3)

			local x, y = 1, -2
			local rx, ry = m:transformPoint(x, y)

			t.assertEqual(rx, 2)
			t.assertEqual(ry, -6)
		end
	}
)
