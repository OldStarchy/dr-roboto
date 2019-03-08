test(
	'BlockManager',
	{
		['Adding items'] = function(t)
			local BlockManager = BlockManager()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace), true)

			local furnace2 = Furnace('furnace2', Position(5, 5, 4, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace2), true)

			local chest = Chest('chest', Position(5, 5, 6, Position.SOUTH))
			t.assertEqual(BlockManager:add(chest), true)

			t.assertTableEqual(BlockManager._blocks, {['Furnace'] = {furnace, furnace2}, ['Chest'] = {chest}})
		end,
		['Removing items'] = function(t)
			local BlockManager = BlockManager()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace), true)
			t.assertEqual(BlockManager:remove(furnace), true)

			t.assertTableEqual(BlockManager._blocks, {['Furnace'] = {}})
		end,
		['Item Duplication'] = function(t)
			local BlockManager = BlockManager()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace), true)
			t.assertEqual(BlockManager:add(furnace), false)

			local chest = Chest('chest', Position(5, 5, 6, Position.SOUTH))
			t.assertEqual(BlockManager:add(chest), true)
			t.assertEqual(BlockManager:add(chest), false)

			t.assertTableEqual(BlockManager._blocks, {['Furnace'] = {furnace}, ['Chest'] = {chest}})
		end,
		['Finding items'] = function(t)
			local BlockManager = BlockManager()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			BlockManager:add(furnace)

			local furnace2 = Furnace('furnace2', Position(5, 5, 4, Position.SOUTH))
			BlockManager:add(furnace2)

			t.assertEqual(BlockManager:findBlockByLocation(furnace.ClassName, furnace.location), furnace)
			t.assertEqual(BlockManager:findBlockByLocation(furnace2.ClassName, furnace2.location), furnace2)

			t.assertEqual(BlockManager:findNearest(Furnace.ClassName, Position()), furnace2)
		end,
		['Saving and loading items'] = function(t)
			local BlockManager = BlockManager()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			BlockManager:add(furnace)

			local chest = Chest('chest', Position(5, 5, 6, Position.SOUTH))
			BlockManager:add(chest)

			BlockManager:saveToFile('test.BlockManager')

			local BlockManager2 = BlockManager.LoadFromFile('test.BlockManager', true)

			t.assertTableEqual(BlockManager2._blocks, {['Furnace'] = {furnace}, ['Chest'] = {chest}})

			BlockManager2:remove(chest)
			BlockManager2:remove(furnace)

			local BlockManager3 = BlockManager.LoadFromFile('test.BlockManager', true)

			t.assertTableEqual(BlockManager3._blocks, {['Furnace'] = {}, ['Chest'] = {}})

			BlockManager3:add(chest)
			BlockManager3:add(furnace)

			local BlockManager4 = BlockManager.LoadFromFile('test.BlockManager', true)
			t.assertTableEqual(BlockManager4._blocks, {['Furnace'] = {furnace}, ['Chest'] = {chest}})
		end
	}
)
