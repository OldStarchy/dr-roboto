test(
	'ItemInfo',
	{
		['Get / Set'] = function(t)
			local ii = ItemInfo()

			t.assertEqual(ii:getStackSize('missing'), 64)

			ii:setStackSize('plank:*', 16)

			t.assertEqual(ii:getStackSize('plank:4'), 16)

			t.assertEqual(ii:getStackSize('plank'), 16)
		end
	}
)
