test(
	'Position',
	{
		Add = function(t)
			local pos = Position.new(5, 5, 5, 2)

			pos:add(Position.new(1, -2, 3, 1))

			t.assertEqual(pos.x, 6)
			t.assertEqual(pos.y, 3)
			t.assertEqual(pos.z, 8)
			t.assertEqual(pos.direction, 3)
		end,
		Sub = function(t)
			local pos = Position.new(5, 5, 5, 2)

			pos:sub(Position.new(1, -2, 3, 1))

			t.assertEqual(pos.x, 4)
			t.assertEqual(pos.y, 7)
			t.assertEqual(pos.z, 2)
			t.assertEqual(pos.direction, 1)
		end,
		['Add Directiona '] = function(t)
			local pos = Position.new(0, 0, 0, 2)

			pos:add(Position.new(0, 0, 0, 3))

			t.assertEqual(pos.direction, 1)
		end,
		['Add Direction b'] = function(t)
			local pos = Position.new(0, 0, 0, 1)

			pos:add(Position.new(0, 0, 0, 7))

			t.assertEqual(pos.direction, 0)
		end,
		['Add Direction a'] = function(t)
			local pos = Position.new(0, 0, 0, 2)

			pos:sub(Position.new(0, 0, 0, 3))

			t.assertEqual(pos.direction, 3)
		end,
		['Add Direction b'] = function(t)
			local pos = Position.new(0, 0, 0, 1)

			pos:sub(Position.new(0, 0, 0, 7))

			t.assertEqual(pos.direction, 2)
		end,
		['Rotate'] = function(t)
			local pos = Position.new(0, 0, 0, 0)

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
			t.assertEqual(Position.wrapDirection(-8), 0)
			t.assertEqual(Position.wrapDirection(-7), 1)
			t.assertEqual(Position.wrapDirection(-6), 2)
			t.assertEqual(Position.wrapDirection(-5), 3)
			t.assertEqual(Position.wrapDirection(-4), 0)
			t.assertEqual(Position.wrapDirection(-3), 1)
			t.assertEqual(Position.wrapDirection(-2), 2)
			t.assertEqual(Position.wrapDirection(-1), 3)
			t.assertEqual(Position.wrapDirection(0), 0)
			t.assertEqual(Position.wrapDirection(1), 1)
			t.assertEqual(Position.wrapDirection(2), 2)
			t.assertEqual(Position.wrapDirection(3), 3)
			t.assertEqual(Position.wrapDirection(4), 0)
			t.assertEqual(Position.wrapDirection(5), 1)
			t.assertEqual(Position.wrapDirection(6), 2)
			t.assertEqual(Position.wrapDirection(7), 3)
			t.assertEqual(Position.wrapDirection(8), 0)
			t.assertEqual(Position.wrapDirection(9), 1)
			t.assertEqual(Position.wrapDirection(10), 2)
			t.assertEqual(Position.wrapDirection(11), 3)
		end
	}
)
