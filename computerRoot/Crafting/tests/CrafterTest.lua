test(
	'Crafter',
	{
		['Raw Items for unknown'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))

			local rawItems = crafting:getRawItems('hat', 1)

			t.assertTableEqual(rawItems, {['hat'] = 1})
		end,
		['Raw Items for many unknown'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))

			local rawItems = crafting:getRawItems('hat', 5)

			t.assertTableEqual(rawItems, {['hat'] = 5})
		end,
		['Raw Items for known'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))
			local book = RecipeBook()

			book:add(CraftingRecipe('hat', {'hat part', 'hat part'}, 1))
			crafting:setRecipeBook(book)

			local rawItems = crafting:getRawItems('hat', 1)

			t.assertTableEqual(rawItems, {['hat part'] = 2})
		end,
		['Raw Items for many known'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))
			local book = RecipeBook()

			book:add(CraftingRecipe('hat', {'hat part', 'hat part'}, 1))
			crafting:setRecipeBook(book)

			local rawItems = crafting:getRawItems('hat', 5)

			t.assertTableEqual(rawItems, {['hat part'] = 10})
		end,
		['Raw Items multiple'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))
			local book = RecipeBook()

			book:add(CraftingRecipe('hat', {'hat part', 'hat part'}, 5))
			crafting:setRecipeBook(book)

			local rawItems = crafting:getRawItems('hat', 5)

			t.assertTableEqual(rawItems, {['hat part'] = 2})
		end,
		['Raw Items combine extras'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))
			local book = RecipeBook()

			book:add(CraftingRecipe('surplus part', {'raw part'}, 4))
			book:add(
				CraftingRecipe(
					'final part',
					{
						'surplus part',
						'surplus part',
						nil,
						'surplus part',
						'surplus part'
					},
					1
				)
			)
			crafting:setRecipeBook(book)

			local rawItems = crafting:getRawItems('final part', 1)

			t.assertTableEqual(rawItems, {['raw part'] = 1})
		end,
		['Recursion'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))
			local book = RecipeBook()

			book:add(
				CraftingRecipe(
					'Iron Block',
					{
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot'
					},
					1
				)
			)
			book:add(CraftingRecipe('Iron Ingot', {'Iron Block'}, 9))
			crafting:setRecipeBook(book)

			local rawItems = crafting:getRawItems('Iron Ingot', 1)

			t.assertTableEqual(rawItems, {['Iron Ingot'] = 1})
		end,
		['Differenciate harvestable from constructable'] = function(t)
			local crafting = Crafter(t.mock('turtle', true))
			local book = RecipeBook()

			book:add(
				CraftingRecipe(
					'Iron Block',
					{
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot',
						'Iron Ingot'
					},
					1
				)
			)
			book:add(CraftingRecipe('Iron Ingot', {'Iron Block'}, 9))
			crafting:setRecipeBook(book)

			local rawItems = crafting:getRawItems('Iron Block', 1)

			t.assertTableEqual(rawItems, {['Iron Ingot'] = 9})
		end
	}
)
