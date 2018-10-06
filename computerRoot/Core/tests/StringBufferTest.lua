test(
	'StringBuffer',
	{
		['Stores data'] = function(t)
			local b = StringBuffer(' ', 100)

			local str = 'This is my buffer'
			b:write(str)

			t.assertEqual(b:read(1, #str), str)
		end,
		['Truncates data at end'] = function(t)
			local b = StringBuffer(' ', 5)

			local str = 'This is my buffer'

			b:write(str)

			local trunc = str:sub(1, 5)
			t.assertEqual(b:read(1, #trunc), trunc)
		end,
		['Truncates data at start'] = function(t)
			local b = StringBuffer(' ', 100)

			local str = 'This is my buffer'

			b:write(str, -10)

			local result = 'buffer'
			t.assertEqual(b:read(1, #result), result)
		end,
		['Rewrites data'] = function(t)
			local b = StringBuffer(' ', 100)

			local str = 'This is my buffer'
			b:write(str)
			b:write('That')

			local result = 'That is my buffer'
			t.assertEqual(b:read(1, #result), result)
		end,
		['Rewrites data at position'] = function(t)
			local b = StringBuffer(' ', 100)

			local str = 'This is my buffer'
			b:write(str)
			b:write('hot dog', 12)

			local result = 'This is my hot dog'
			t.assertEqual(b:read(1, #result), result)
		end,
		['Reads data at position'] = function(t)
			local b = StringBuffer(' ', 100)

			local str = 'This is my long string'
			b:write(str)

			local result = 'my long string'
			t.assertEqual(b:read(9, 9 + #result - 1), result)
		end,
		['Initial data'] = function(t)
			local b = StringBuffer(' ', 100)

			local result = '            '
			t.assertEqual(b:read(1, #result), result)
		end
	}
)
