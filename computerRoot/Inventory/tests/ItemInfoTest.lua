test(
	'ItemInfo',
	{
		['Get / Set'] = function(t)
			local ii = ItemInfo()

			ii:setStackSize('lava_bucket:*', 1)
			ii:setBurnTime('lava_bucket:*', 1000)

			t.assertEqual(ii:getStackSize('missing'), 64)
			t.assertEqual(ii:getBurnTime('missing'), nil)
			t.assertEqual(ii:getStackSize('lava_bucket:0'), 1)
			t.assertEqual(ii:getBurnTime('lava_bucket:0'), 1000)
		end
	}
)
