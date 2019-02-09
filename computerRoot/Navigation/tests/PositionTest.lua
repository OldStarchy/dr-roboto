test(
	'Position',
	{
		Add = function(t)
			local pos = Position(5, 5, 5, 2)

			pos:add(Position(1, -2, 3, 1))

			t.assertEqual(pos.x, 6)
			t.assertEqual(pos.y, 3)
			t.assertEqual(pos.z, 8)
			t.assertEqual(pos.direction, 3)
		end,
		Sub = function(t)
			local pos = Position(5, 5, 5, 2)

			pos:sub(Position(1, -2, 3, 1))

			t.assertEqual(pos.x, 4)
			t.assertEqual(pos.y, 7)
			t.assertEqual(pos.z, 2)
			t.assertEqual(pos.direction, 1)
		end,
		['Add Directiona '] = function(t)
			local pos = Position(0, 0, 0, 2)

			pos:add(Position(0, 0, 0, 3))

			t.assertEqual(pos.direction, 1)
		end,
		['Add Direction b'] = function(t)
			local pos = Position(0, 0, 0, 1)

			pos:add(Position(0, 0, 0, 7))

			t.assertEqual(pos.direction, 0)
		end,
		['Add Direction a'] = function(t)
			local pos = Position(0, 0, 0, 2)

			pos:sub(Position(0, 0, 0, 3))

			t.assertEqual(pos.direction, 3)
		end,
		['Add Direction b'] = function(t)
			local pos = Position(0, 0, 0, 1)

			pos:sub(Position(0, 0, 0, 7))

			t.assertEqual(pos.direction, 2)
		end,
		['Rotate'] = function(t)
			local pos = Position(0, 0, 0, 0)

			pos:rotate(1)
			t.assertEqual(pos.direction, 1)
			pos:rotate(1)
			t.assertEqual(pos.direction, 2)
			pos:rotate(1)
			t.assertEqual(pos.direction, 3)
			pos:rotate(1)
			t.assertEqual(pos.direction, 0)
			pos:rotate(2)
			t.assertEqual(pos.direction, 2)
			pos:rotate(2)
			t.assertEqual(pos.direction, 0)
			pos:rotate(-1)
			t.assertEqual(pos.direction, 3)
			pos:rotate(-7)
			t.assertEqual(pos.direction, 0)
			pos:rotate(-6)
			t.assertEqual(pos.direction, 2)
		end,
		['Wrap Direction'] = function(t)
			t.assertEqual(Position.WrapDirection(-8), 0)
			t.assertEqual(Position.WrapDirection(-7), 1)
			t.assertEqual(Position.WrapDirection(-6), 2)
			t.assertEqual(Position.WrapDirection(-5), 3)
			t.assertEqual(Position.WrapDirection(-4), 0)
			t.assertEqual(Position.WrapDirection(-3), 1)
			t.assertEqual(Position.WrapDirection(-2), 2)
			t.assertEqual(Position.WrapDirection(-1), 3)
			t.assertEqual(Position.WrapDirection(0), 0)
			t.assertEqual(Position.WrapDirection(1), 1)
			t.assertEqual(Position.WrapDirection(2), 2)
			t.assertEqual(Position.WrapDirection(3), 3)
			t.assertEqual(Position.WrapDirection(4), 0)
			t.assertEqual(Position.WrapDirection(5), 1)
			t.assertEqual(Position.WrapDirection(6), 2)
			t.assertEqual(Position.WrapDirection(7), 3)
			t.assertEqual(Position.WrapDirection(8), 0)
			t.assertEqual(Position.WrapDirection(9), 1)
			t.assertEqual(Position.WrapDirection(10), 2)
			t.assertEqual(Position.WrapDirection(11), 3)
		end
	}
)
