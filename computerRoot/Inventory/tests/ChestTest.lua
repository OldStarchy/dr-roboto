test(
	'Chest',
	{
		Constructor = {
			['Single Chest Constructor'] = function(t)
				local p = Position(5, 5, 5, Position.SOUTH)
				local chest = Chest(t.testName, p, false)

				chest:remove()
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
			end,
			['Chest Get Item At'] = function(t)
				local chest = Chest(t.testName, Position(5, 5, 5, Position.SOUTH), false)
				chest:clear()

				chest:push('bucket', 33)
				chest:push('cobblestone', 65)
				chest:push('shovel', 4)

				assert(chest:getItemAt(1) == 'bucket', 'item not found in chest')
				assert(chest:getItemAt(2) == 'bucket', 'item not found in chest')
				assert(chest:getItemAt(3) == 'bucket', 'item not found in chest')
				assert(chest:getItemAt(4) == 'cobblestone', 'item not found in chest')
				assert(chest:getItemAt(5) == 'cobblestone', 'item not found in chest')
				assert(chest:getItemAt(6) == 'shovel', 'item not found in chest')
				assert(chest:getItemAt(7) == 'shovel', 'item not found in chest')
				assert(chest:getItemAt(8) == 'shovel', 'item not found in chest')
				assert(chest:getItemAt(9) == 'shovel', 'item not found in chest')

				--assert(chest:pop(3) == 'bucket', 'item not found in chest')
				--assert(chest:pop(5) == 'cobblestone', 'item not found in chest')
				--assert(chest:pop(9) == 'shovel', 'item not found in chest')

				--chest:remove()
			end
		}
	}
)
