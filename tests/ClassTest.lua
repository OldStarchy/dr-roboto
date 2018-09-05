test(
	'Class Constructor',
	{
		['Called'] = function(t)
			local A = Class()

			local constructorCalled = false

			A.constructor = function()
				constructorCalled = true
			end

			local object = A.new()

			t.assertEqual(constructorCalled, true)
		end,
		['Called With Colon'] = function(t)
			local A = Class()

			local constructorCalled = false

			A.constructor = function()
				constructorCalled = true
			end

			local object = A:new()

			t.assertEqual(constructorCalled, true)
		end,
		['Passes self'] = function(t)
			local A = Class()

			local selfValue = nil

			A.constructor = function(self)
				selfValue = self
			end

			local object = A.new()

			t.assertNotEqual(selfValue, nil)
			t.assertEqual(selfValue, object)
		end,
		['With Colon Passes self'] = function(t)
			local A = Class()

			local selfValue = nil

			A.constructor = function(self)
				selfValue = self
			end

			local object = A:new()

			t.assertNotEqual(selfValue, nil)
			t.assertEqual(selfValue, object)
		end,
		['Recieves Arguments'] = function(t)
			local A = Class()

			local aValue = nil
			local bValue = nil
			local cValue = nil

			A.constructor = function(self, a, b, c)
				aValue = a
				bValue = b
				cValue = c
			end

			local tmpTable = {}
			local object = A.new(5, 'blah', tmpTable)

			t.assertNotEqual(a, nil)
			t.assertNotEqual(b, nil)
			t.assertNotEqual(c, nil)
			t.assertEqual(aValue, 5)
			t.assertEqual(bValue, 'blah')
			t.assertEqual(cValue, tmpTable)
		end,
		['With Colon Recieves Arguments'] = function(t)
			local A = Class()

			local aValue = nil
			local bValue = nil
			local cValue = nil

			A.constructor = function(self, a, b, c)
				aValue = a
				bValue = b
				cValue = c
			end

			local tmpTable = {}
			local object = A:new(5, 'blah', tmpTable)

			t.assertNotEqual(a, nil)
			t.assertNotEqual(b, nil)
			t.assertNotEqual(c, nil)
			t.assertEqual(aValue, 5)
			t.assertEqual(bValue, 'blah')
			t.assertEqual(cValue, tmpTable)
		end
	}
)
