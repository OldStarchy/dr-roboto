test(
	'BlockMap',
	{
		['Adding items'] = function(t)
			local blockMap = BlockMap()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(blockMap:add(furnace), true)

			local furnace2 = Furnace('furnace2', Position(5, 5, 4, Position.SOUTH))
			t.assertEqual(blockMap:add(furnace2), true)

			local chest = Chest('chest', Position(5, 5, 6, Position.SOUTH))
			t.assertEqual(blockMap:add(chest), true)

			t.assertTableEqual(blockMap._blocks, {['Furnace'] = {furnace, furnace2}, ['Chest'] = {chest}})
		end,
		['Removing items'] = function(t)
			local blockMap = BlockMap()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(blockMap:add(furnace), true)
			t.assertEqual(blockMap:remove(furnace), true)

			t.assertTableEqual(blockMap._blocks, {['Furnace'] = {}})
		end,
		['Item Duplication'] = function(t)
			local blockMap = BlockMap()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(blockMap:add(furnace), true)
			t.assertEqual(blockMap:add(furnace), false)

			local chest = Chest('chest', Position(5, 5, 6, Position.SOUTH))
			t.assertEqual(blockMap:add(chest), true)
			t.assertEqual(blockMap:add(chest), false)

			t.assertTableEqual(blockMap._blocks, {['Furnace'] = {furnace}, ['Chest'] = {chest}})
		end,
		['Finding items'] = function(t)
			local blockMap = BlockMap()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			blockMap:add(furnace)

			local furnace2 = Furnace('furnace2', Position(5, 5, 4, Position.SOUTH))
			blockMap:add(furnace2)

			t.assertEqual(blockMap:findBlockByLocation(furnace.ClassName, furnace.location), furnace)
			t.assertEqual(blockMap:findBlockByLocation(furnace2.ClassName, furnace2.location), furnace2)

			t.assertEqual(blockMap:findNearest(Furnace.ClassName, Position()), furnace2)
		end,
		['Saving and loading items'] = function(t)
			local blockMap = BlockMap()

			local furnace = Furnace('furnace', Position(5, 5, 5, Position.SOUTH))
			blockMap:add(furnace)

			local chest = Chest('chest', Position(5, 5, 6, Position.SOUTH))
			blockMap:add(chest)

			blockMap:saveToFile('test.blockmap')

			local blockMap2 = BlockMap.LoadFromFile('test.blockmap', true)

			t.assertTableEqual(blockMap2._blocks, {['Furnace'] = {furnace}, ['Chest'] = {chest}})

			blockMap2:remove(chest)
			blockMap2:remove(furnace)

			local blockMap3 = BlockMap.LoadFromFile('test.blockmap', true)

			t.assertTableEqual(blockMap3._blocks, {['Furnace'] = {}, ['Chest'] = {}})

			blockMap3:add(chest)
			blockMap3:add(furnace)

			local blockMap4 = BlockMap.LoadFromFile('test.blockmap', true)
			t.assertTableEqual(blockMap4._blocks, {['Furnace'] = {furnace}, ['Chest'] = {chest}})
		end
	}
)
