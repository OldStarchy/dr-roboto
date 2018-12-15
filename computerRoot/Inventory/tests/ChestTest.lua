test(
	'Chest',
	{
		Constructor = {
			['Single Chest Constructor'] = function(t)
				local p = Position(5, 5, 5, Position.SOUTH)
				local chest = Chest(t.testName, p, false)

				chest:remove()

				t.assertFinished()
			end,
			['Single Chest fill'] = function(t)
				ItemInfo.Instance = ItemInfo()
				ItemInfo.Instance:setStackSize('item', 64)

				local chest = Chest(t.testName, Position(5, 5, 5, Position.SOUTH), false)

				chest:push('item', chest:size() * 64)

				t.assertEqual(chest:getItemAt(chest:size()), 'item')
				t.assertEqual(chest:getItemCount(chest:size()), 64)
				t.assertEqual(chest:getItemSpace(chest:size()), 0)
				t.assertEqual(chest:getTotalSpaceFor('item'), 0)
				t.assertEqual(chest:canPush('item', 1), false)
				t.assertEqual(chest:push('item', 1), false)
				t.assertEqual(chest:isEmpty(), false)

				--TODO: move to a different test
				t.assertEqual(chest:has('item'), true)

				chest:remove()
			end
		},
		['Chest Item Placement'] = function(t)
			ItemInfo.Instance = ItemInfo()
			ItemInfo.Instance:setStackSize('bucket', 16)
			ItemInfo.Instance:setStackSize('cobblestone', 64)
			ItemInfo.Instance:setStackSize('shovel', 1)

			local chest = Chest(t.testName, Position(5, 5, 5, Position.SOUTH), false)
			chest:clear()

			chest:push('bucket', 33)
			chest:push('cobblestone', 65)
			chest:push('shovel', 4)

			--Should result in chest as follows

			-- bucket x 16
			-- bucket x 16
			-- bucket x 1
			-- cobblestone x 64
			-- cobblestone x 1
			-- shovel x 1
			-- shovel x 1
			-- shovel x 1
			-- shovel x 1

			t.assertEqual(chest:getItemAt(1), 'bucket')
			t.assertEqual(chest:getItemAt(2), 'bucket')
			t.assertEqual(chest:getItemAt(3), 'bucket')
			t.assertEqual(chest:getItemAt(4), 'cobblestone')
			t.assertEqual(chest:getItemAt(5), 'cobblestone')
			t.assertEqual(chest:getItemAt(6), 'shovel')
			t.assertEqual(chest:getItemAt(7), 'shovel')
			t.assertEqual(chest:getItemAt(8), 'shovel')
			t.assertEqual(chest:getItemAt(9), 'shovel')
			t.assertEqual(chest:getItemAt(10), nil)

			--assert(chest:pop(3) == 'bucket', 'item not found in chest')
			--assert(chest:pop(5) == 'cobblestone', 'item not found in chest')
			--assert(chest:pop(9) == 'shovel', 'item not found in chest')
			t.assertEqual(chest:getTotalSpaceFor('shovel'), (27 - 9) * ItemInfo.Instance:getStackSize('shovel'))
			t.assertEqual(chest:getTotalSpaceFor('bucket'), 15 + (27 - 9) * ItemInfo.Instance:getStackSize('bucket'))
			t.assertEqual(chest:getTotalSpaceFor('cobblestone'), 63 + (27 - 9) * ItemInfo.Instance:getStackSize('cobblestone'))

			chest:remove()
		end,
		['Chest Pop'] = function(t)
			ItemInfo.Instance = ItemInfo()
			ItemInfo.Instance:setStackSize('bucket', 16)
			ItemInfo.Instance:setStackSize('cobblestone', 64)
			ItemInfo.Instance:setStackSize('shovel', 1)

			local chest = Chest(t.testName, Position(5, 5, 5, Position.SOUTH), false)
			chest:clear()

			chest:push('bucket', 3)
			chest:push('cobblestone', 2)
			chest:push('shovel', 1)

			--Should result in chest as follows

			-- bucket x 1
			-- cobblestone x 1
			-- shovel x 1

			t.assertEqual(chest:getItemCount(1), 3)
			t.assertEqual(chest:getItemSpace(1), 13)
			t.assertEqual(chest:peek(), 'bucket')
			local b, bc = chest:pop()
			t.assertEqual(b, 'bucket')
			t.assertEqual(bc, 3)

			t.assertEqual(chest:getItemCount(2), 2)
			t.assertEqual(chest:getItemSpace(2), 62)
			t.assertEqual(chest:peek(), 'cobblestone')
			local c, cc = chest:pop()
			t.assertEqual(c, 'cobblestone')
			t.assertEqual(cc, 2)

			t.assertEqual(chest:getItemCount(3), 1)
			t.assertEqual(chest:getItemSpace(3), 0)
			t.assertEqual(chest:peek(), 'shovel')
			local s, sc = chest:pop()
			t.assertEqual(s, 'shovel')
			t.assertEqual(sc, 1)

			chest:remove()
		end
	}
)
