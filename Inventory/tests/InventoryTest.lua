test(
	'Inventory',
	{
		Add = function(t)
			local i = Inventory()

			i:add(
				{
					name = 'minecraft:dirt',
					damage = 0,
					count = 3
				}
			)
			i:add(
				{
					name = 'minecraft:cobblestone',
					damage = 0,
					count = 3
				}
			)

			t.assertTableEqual(
				i._items,
				{
					{
						name = 'minecraft:dirt',
						damage = 0,
						count = 3
					},
					{
						name = 'minecraft:cobblestone',
						damage = 0,
						count = 3
					}
				}
			)
		end,
		Remove = function(t)
			local i = Inventory()

			i:add(
				{
					name = 'minecraft:dirt',
					damage = 0,
					count = 3
				}
			)
			i:add(
				{
					name = 'minecraft:cobblestone',
					damage = 0,
					count = 3
				}
			)

			i:remove('dirt', 1)

			t.assertTableEqual(
				i._items,
				{
					{
						name = 'minecraft:dirt',
						damage = 0,
						count = 2
					},
					{
						name = 'minecraft:cobblestone',
						damage = 0,
						count = 3
					}
				}
			)
		end,
		Push = function(t)
			local i = Inventory()

			i:add(
				{
					name = 'minecraft:dirt',
					damage = 0,
					count = 3
				}
			)
			i:add(
				{
					name = 'minecraft:cobblestone',
					damage = 0,
					count = 3
				}
			)

			i:push()
			i:remove('dirt', 1)

			print(tableToString(i._stack))

			t.assertTableEqual(
				i._stack,
				{
					{
						{
							name = 'minecraft:dirt',
							damage = 0,
							count = 3
						},
						{
							name = 'minecraft:cobblestone',
							damage = 0,
							count = 3
						}
					}
				}
			)
		end,
		Pop = function(t)
			local i = Inventory()

			i:add(
				{
					name = 'minecraft:dirt',
					damage = 0,
					count = 3
				}
			)
			i:add(
				{
					name = 'minecraft:cobblestone',
					damage = 0,
					count = 3
				}
			)

			i:push()
			i:remove('dirt', 1)
			i:pop()

			t.assertTableEqual(
				i._items,
				{
					{
						name = 'minecraft:dirt',
						damage = 0,
						count = 3
					},
					{
						name = 'minecraft:cobblestone',
						damage = 0,
						count = 3
					}
				}
			)
		end,
		['Pop too much'] = function(t)
			local i = Inventory()
			i:push()
			i:pop()

			t.assertThrows(
				function()
					i:pop()
				end
			)
		end
	}
)
