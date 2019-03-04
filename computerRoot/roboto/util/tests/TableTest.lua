test(
	'cloneTable',
	{
		Environment = function(t)
			local a = ItemStackDetail('a', 1, 2)

			assertType(a, ItemStackDetail)

			local b = cloneTable(a)

			assertType(b, ItemStackDetail)

			t.assertFinished()
		end
	}
)
