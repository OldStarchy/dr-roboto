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
				local chest = Chest(t.testName, Position(5, 5, 5, Position.SOUTH), false)

				chest:push('item', chest:size() * 64)
				assert(chest:getItemAt(chest:size()) == 'item', 'item not found in chest')

				assert(chest:getItemCount(chest:size()) == 64, 'item count in chest for slot is incorrect')

				assert(chest:getItemSpace(chest:size()) == 0, 'item space in chest for slot is incorrect')

				assert(chest:getTotalSpaceFor('item') == 0, 'item space in chest in incorrect')

				assert(chest:canPush('item', 1) == false, 'chest can push in incorrect')

				assert(chest:push('item', 1) == false, 'chest can push in incorrect')

				assert(chest:has('item') == true, 'chest has Item is not correct')

				assert(chest:isEmpty() == false, 'chest is empty is not correct')

				chest:remove()
			end
		},
		['Chest Item Placement'] = function(t)
			ItemInfo.DefaultItemInfo = ItemInfo()
			local io = ItemInfo.DefaultItemInfo

			io:setStackSize('bucket', 16)
			io:setStackSize('cobblestone', 64)
			io:setStackSize('shovel', 1)

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

			--chest:remove()
		end
	}
)
