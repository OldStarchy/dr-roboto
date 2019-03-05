test(
	'ItemStore',
	{
		Push = function(t)
			ItemInfo.Instance = ItemInfo()
			local i = ItemStore(27)

			i:push(ItemStackDetail('minecraft:dirt', 0, 3))
			i:push(ItemStackDetail('minecraft:cobblestone', 0, 3))

			t.assertTableEqual(
				i._items,
				{
					ItemStackDetail('minecraft:dirt', 0, 3),
					ItemStackDetail('minecraft:cobblestone', 0, 3)
				}
			)
		end,
		Pop1 = function(t)
			ItemInfo.Instance = ItemInfo()
			local i = ItemStore(27)

			i:push(ItemStackDetail('minecraft:dirt', 0, 3))
			i:push(ItemStackDetail('minecraft:cobblestone', 0, 3))

			t.assertTableEqual(i:pop(), ItemStackDetail('minecraft:dirt', 0, 3))

			t.assertTableEqual(
				i._items,
				{
					nil,
					ItemStackDetail('minecraft:cobblestone', 0, 3)
				}
			)
		end,
		PopAll = function(t)
			ItemInfo.Instance = ItemInfo()
			local i = ItemStore(27)

			i:push(ItemStackDetail('minecraft:dirt', 0, 3))
			i:push(ItemStackDetail('minecraft:cobblestone', 0, 3))

			t.assertTableEqual(i:pop(), ItemStackDetail('minecraft:dirt', 0, 3))
			t.assertTableEqual(i:pop(), ItemStackDetail('minecraft:cobblestone', 0, 3))

			t.assertTableEqual(i._items, {})
		end,
		PushState = function(t)
			ItemInfo.Instance = ItemInfo()
			local i = ItemStore(27)

			i:push(ItemStackDetail('minecraft:dirt', 0, 3))
			i:push(ItemStackDetail('minecraft:cobblestone', 0, 3))

			i:pushState()
			i:pop()

			t.assertTableEqual(
				i._stateStack,
				{
					{
						ItemStackDetail('minecraft:dirt', 0, 3),
						ItemStackDetail('minecraft:cobblestone', 0, 3)
					}
				}
			)
		end,
		PopState = function(t)
			ItemInfo.Instance = ItemInfo()
			local i = ItemStore(27)

			i:push(ItemStackDetail('minecraft:dirt', 0, 3))
			i:push(ItemStackDetail('minecraft:cobblestone', 0, 3))

			i:pushState()
			i:pop()
			i:popState()

			t.assertTableEqual(
				i._items,
				{
					ItemStackDetail('minecraft:dirt', 0, 3),
					ItemStackDetail('minecraft:cobblestone', 0, 3)
				}
			)
		end,
		['PopState too much'] = function(t)
			ItemInfo.Instance = ItemInfo()
			local i = ItemStore(27)
			i:pushState()
			i:popState()

			t.assertThrows(
				function()
					i:popState()
				end
			)
		end,
		Fill = function(t)
			ItemInfo.Instance = ItemInfo()
			ItemInfo.Instance:setStackSize('item', 64)

			local store = ItemStore(27)

			store:push(ItemStackDetail('item', 0, 64 * store:size()))

			t.assertEqual(store:getItemAt(store:size()).name, 'minecraft:item')
			t.assertEqual(store:getItemCount(store:size()), 64)
			t.assertEqual(store:getItemSpace(store:size()), 0)
			t.assertEqual(store:getTotalSpaceFor('item'), 0)
			t.assertEqual(store:canPush('item', 1), false)
			t.assertThrows(
				function()
					store:push(ItemStackDetail('item', 0, 1))
				end
			)
			t.assertEqual(store:isEmpty(), false)

			--TODO: move to a different test
			t.assertEqual(store:has('item'), true)
		end,
		['Multiple Item Distribution'] = function(t)
			ItemInfo.Instance = ItemInfo()
			ItemInfo.Instance:setStackSize('bucket', 16)
			ItemInfo.Instance:setStackSize('cobblestone', 64)
			ItemInfo.Instance:setStackSize('shovel', 1)

			local store = ItemStore(27)

			store:push(ItemStackDetail('bucket', 0, 33))
			store:push(ItemStackDetail('cobblestone', 0, 65))
			store:push(ItemStackDetail('shovel', 0, 4))

			--Should result in store as follows

			-- bucket x 16
			-- bucket x 16
			-- bucket x 1
			-- cobblestone x 64
			-- cobblestone x 1
			-- shovel x 1
			-- shovel x 1
			-- shovel x 1
			-- shovel x 1

			t.assertEqual(store:getItemAt(1).name, 'minecraft:bucket')
			t.assertEqual(store:getItemAt(2).name, 'minecraft:bucket')
			t.assertEqual(store:getItemAt(3).name, 'minecraft:bucket')
			t.assertEqual(store:getItemAt(4).name, 'minecraft:cobblestone')
			t.assertEqual(store:getItemAt(5).name, 'minecraft:cobblestone')
			t.assertEqual(store:getItemAt(6).name, 'minecraft:shovel')
			t.assertEqual(store:getItemAt(7).name, 'minecraft:shovel')
			t.assertEqual(store:getItemAt(8).name, 'minecraft:shovel')
			t.assertEqual(store:getItemAt(9).name, 'minecraft:shovel')
			t.assertEqual(store:getItemAt(10), nil)

			--assert(store:pop(3) == 'bucket', 'item not found in store')
			--assert(store:pop(5) == 'cobblestone', 'item not found in store')
			--assert(store:pop(9) == 'shovel', 'item not found in store')
			t.assertEqual(store:getTotalSpaceFor('shovel'), (27 - 9) * ItemInfo.Instance:getStackSize('shovel'))
			t.assertEqual(store:getTotalSpaceFor('bucket'), 15 + (27 - 9) * ItemInfo.Instance:getStackSize('bucket'))
			t.assertEqual(store:getTotalSpaceFor('cobblestone'), 63 + (27 - 9) * ItemInfo.Instance:getStackSize('cobblestone'))
		end,
		['Item Removal'] = function(t)
			ItemInfo.Instance = ItemInfo()
			ItemInfo.Instance:setStackSize('bucket', 16)
			ItemInfo.Instance:setStackSize('cobblestone', 64)
			ItemInfo.Instance:setStackSize('shovel', 1)

			local store = ItemStore(27)

			store:push(ItemStackDetail('bucket', 0, 3))
			store:push(ItemStackDetail('cobblestone', 0, 2))
			store:push(ItemStackDetail('shovel', 0, 1))

			--Should result in store as follows

			-- bucket x 1
			-- cobblestone x 1
			-- shovel x 1

			t.assertEqual(store:getItemCount(1), 3)
			t.assertEqual(store:getItemSpace(1), 13)
			t.assertTableEqual(store:peek(), ItemStackDetail('bucket', 0, 3))

			t.assertTableEqual(store:pop(), ItemStackDetail('bucket', 0, 3))

			t.assertEqual(store:getItemCount(2), 2)
			t.assertEqual(store:getItemSpace(2), 62)
			t.assertTableEqual(store:peek(), ItemStackDetail('cobblestone', 0, 2))

			t.assertTableEqual(store:pop(), ItemStackDetail('cobblestone', 0, 2))

			t.assertEqual(store:getItemCount(3), 1)
			t.assertEqual(store:getItemSpace(3), 0)

			t.assertTableEqual(store:peek(), ItemStackDetail('shovel', 0, 1))
			t.assertTableEqual(store:pop(), ItemStackDetail('shovel', 0, 1))
		end
	}
)
