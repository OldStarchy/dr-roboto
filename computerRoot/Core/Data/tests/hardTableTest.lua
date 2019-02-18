test(
	'hardTable',
	{
		Value = function(t)
			local a = hardTable('atable')
			a.b = 3
			t.assertEqual(a.b, 3)
		end,
		InnerTable = function(t)
			local a = hardTable('btable')
			a.b = {}
			a.b.v = 'hello'

			t.assertEqual(a.b.v, 'hello')
		end
	}
)
