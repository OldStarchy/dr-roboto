test(
	'BlockManager',
	{
		['Adding items'] = function(t)
			local BlockManager = BlockManager(Map())

			local furnace = Furnace(Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace), true)

			local furnace2 = Furnace(Position(5, 5, 4, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace2), true)

			local chest = Chest(Position(5, 5, 6, Position.SOUTH), true)
			t.assertEqual(BlockManager:add(chest), true)

			t.assertTableEqual(BlockManager._blocks, {furnace, furnace2, chest})
		end,
		['Removing items'] = function(t)
			local BlockManager = BlockManager(Map())

			local furnace = Furnace(Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace), true)
			t.assertEqual(BlockManager:remove(furnace), true)

			t.assertTableEqual(BlockManager._blocks, {})
		end,
		['Item Duplication'] = function(t)
			local BlockManager = BlockManager(Map())

			local furnace = Furnace(Position(5, 5, 5, Position.SOUTH))
			t.assertEqual(BlockManager:add(furnace), true)
			t.assertEqual(BlockManager:add(furnace), false)

			local chest = Chest(Position(5, 5, 6, Position.SOUTH), true)
			t.assertEqual(BlockManager:add(chest), true)
			t.assertEqual(BlockManager:add(chest), false)

			t.assertTableEqual(BlockManager._blocks, {furnace, chest})
		end,
		['Finding items'] = function(t)
			local BlockManager = BlockManager(Map())

			local furnace = Furnace(Position(5, 5, 5, Position.SOUTH))
			BlockManager:add(furnace)

			local furnace2 = Furnace(Position(5, 5, 4, Position.SOUTH))
			BlockManager:add(furnace2)

			t.assertEqual(BlockManager:findBlockByLocation(furnace.location), furnace)
			t.assertEqual(BlockManager:findBlockByLocation(furnace2.location), furnace2)

			t.assertEqual(BlockManager:findNearest(Position()), furnace2)
		end,
		['Saving and loading items'] = function(t)
			Map.Instance = Map()
			local BlockManager = BlockManager(Map.Instance)

			local furnace = Furnace(Position(5, 5, 5, Position.SOUTH))
			BlockManager:add(furnace)

			local chest = Chest(Position(5, 5, 6, Position.SOUTH), true)
			BlockManager:add(chest)

			local tbl = BlockManager:serialize()

			local BlockManager2 = BlockManager.Deserialize(tbl)

			t.assertTableEqual(BlockManager2._blocks, {furnace, chest})

			BlockManager2:remove(chest)
			BlockManager2:remove(furnace)

			local tbl2 = BlockManager2:serialize()

			local BlockManager3 = BlockManager.Deserialize(tbl2)

			t.assertTableEqual(BlockManager3._blocks, {})

			BlockManager3:add(chest)
			BlockManager3:add(furnace)

			local tbl3 = BlockManager3:serialize()

			local BlockManager4 = BlockManager.Deserialize(tbl3)
			t.assertTableEqual(BlockManager4._blocks, {chest, furnace})
		end
	}
)
