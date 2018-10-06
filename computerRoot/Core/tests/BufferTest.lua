test(
	'Buffer',
	{
		['Stores data'] = function(t)
			local b = Buffer(0, 100)

			local vals = {
				5,
				3,
				2,
				'hey',
				1
			}
			b:write(vals)

			t.assertTableEqual(b:read(1, #vals), vals)
		end,
		['Truncates data at end'] = function(t)
			local b = Buffer(0, 5)

			local vals = {
				5,
				3,
				2,
				'hey',
				1,
				24,
				21
			}

			b:write(vals)

			local trunc = {
				5,
				3,
				2,
				'hey',
				1
			}
			t.assertTableEqual(b:read(1, #trunc), trunc)
		end,
		['Truncates data at start'] = function(t)
			local b = Buffer(0, 100)

			local vals = {
				5,
				3,
				2,
				'hey',
				nil,
				3,
				2,
				4,
				1,
				1,
				nil,
				34,
				35,
				4,
				6,
				2,
				4
			}

			b:write(vals, -10)

			local result = {
				34,
				35,
				4,
				6,
				2,
				4
			}
			t.assertTableEqual(b:read(1, #result), result)
		end,
		['Rewrites data'] = function(t)
			local b = Buffer(0, 100)

			local vals = {
				5,
				3,
				2,
				'hey',
				1
			}
			b:write(vals)
			b:write(
				{
					1,
					1,
					3
				}
			)

			local result = {
				1,
				1,
				3,
				'hey',
				1
			}
			t.assertTableEqual(b:read(1, #result), result)
		end,
		['Rewrites data at position'] = function(t)
			local b = Buffer(0, 100)

			local vals = {
				5,
				3,
				2,
				'hey',
				1
			}
			b:write(vals)
			b:write({99, 'this is arbitrary', 32}, 4)

			local result = {
				5,
				3,
				2,
				99,
				'this is arbitrary',
				32
			}
			t.assertTableEqual(b:read(1, #result), result)
		end,
		['Reads data at position'] = function(t)
			local b = Buffer(0, 100)

			local vals = {
				5,
				3,
				2,
				'hey',
				1
			}
			b:write(vals)

			local result = {
				2,
				'hey',
				1
			}
			t.assertTableEqual(b:read(3, 3 + #result - 1), result)
		end,
		['Initial data'] = function(t)
			local b = Buffer(0, 100)

			local result = {
				0,
				0,
				0,
				0,
				0,
				0,
				0
			}
			t.assertTableEqual(b:read(1, #result), result)
		end
	}
)
