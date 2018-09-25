local function getItem(name)
	return ({
		dirt = {
			count = 1,
			name = 'minecraft:dirt',
			damage = 0
		},
		cobblestone = {
			count = 1,
			name = 'minecraft:cobblestone',
			damage = 0
		},
		oak = {
			count = 1,
			name = 'minecraft:log',
			damage = 0
		},
		spruce = {
			count = 1,
			name = 'minecraft:log',
			damage = 1
		},
		birch = {
			count = 1,
			name = 'minecraft:log',
			damage = 2
		}
	})[name]
end
test(
	'Inventory',
	{
		ItemIs = {
			Explicit = function(t)
				local selector = 'minecraft:log:0'
				t.assertEqual(InventoryManager.ItemIs(getItem('oak'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('dirt'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('birch'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('spruce'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('cobblestone'), selector), false)
			end,
			ImplicitNamespace = function(t)
				local selector = 'log:0'
				t.assertEqual(InventoryManager.ItemIs(getItem('oak'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('dirt'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('birch'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('spruce'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('cobblestone'), selector), false)
			end,
			ImplicitDamage = function(t)
				local selector = 'log'
				t.assertEqual(InventoryManager.ItemIs(getItem('oak'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('dirt'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('birch'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('spruce'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('cobblestone'), selector), false)
			end,
			DamageValue = function(t)
				local selector = 'log:1'
				t.assertEqual(InventoryManager.ItemIs(getItem('oak'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('dirt'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('birch'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('spruce'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('cobblestone'), selector), false)
			end,
			SubSelectors = function(t)
				local selector = 'dirt,log:2,cobblestone'
				t.assertEqual(InventoryManager.ItemIs(getItem('oak'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('dirt'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('birch'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('spruce'), selector), false)
				t.assertEqual(InventoryManager.ItemIs(getItem('cobblestone'), selector), true)
			end,
			Anything = function(t)
				local selector = '*'
				t.assertEqual(InventoryManager.ItemIs(getItem('oak'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('dirt'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('birch'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('spruce'), selector), true)
				t.assertEqual(InventoryManager.ItemIs(getItem('cobblestone'), selector), true)
			end,
			SpecialChars = function(t)
				local selector = 'Something-Something'
				t.assertEqual(
					InventoryManager.ItemIs(
						{
							count = 1,
							name = 'myMod:Something-Something',
							damage = 0
						},
						selector
					),
					true
				)
			end
		}
	}
)
