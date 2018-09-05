test(
	'Class',
	{
		Constructor = {
			['Called'] = function(t)
				local A = Class()

				local constructorCalled = false

				A.constructor = function()
					constructorCalled = true
				end

				local object = A.new()

				t.assertEqual(constructorCalled, true)
			end,
			['Missing'] = function(t)
				local A = Class()

				local object = A.new()
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

				t.assertNotEqual(aValue, nil)
				t.assertNotEqual(bValue, nil)
				t.assertNotEqual(cValue, nil)
				t.assertEqual(aValue, 5)
				t.assertEqual(bValue, 'blah')
				t.assertEqual(cValue, tmpTable)
			end
		},
		Method = {
			['Called'] = function(t)
				local A = Class()

				local methodCalled = false

				A.method = function()
					methodCalled = true
				end

				local object = A.new()
				object:method()

				t.assertEqual(methodCalled, true)
			end,
			['Missing'] = function(t)
				local A = Class()

				local object = A.new()

				t.assertThrows(
					function()
						object:missingMethod()
					end
				)
			end,
			['Passes self'] = function(t)
				local A = Class()

				local selfValue = nil

				A.method = function(self)
					selfValue = self
				end

				local object = A.new()
				object:method()

				t.assertNotEqual(selfValue, nil)
				t.assertEqual(selfValue, object)
			end,
			['Recieves Arguments'] = function(t)
				local A = Class()

				local aValue = nil
				local bValue = nil
				local cValue = nil

				A.method = function(self, a, b, c)
					aValue = a
					bValue = b
					cValue = c
				end

				local tmpTable = {}
				local object = A.new()
				object:method(5, 'blah', tmpTable)

				t.assertNotEqual(aValue, nil)
				t.assertNotEqual(bValue, nil)
				t.assertNotEqual(cValue, nil)
				t.assertEqual(aValue, 5)
				t.assertEqual(bValue, 'blah')
				t.assertEqual(cValue, tmpTable)
			end
		}
		--TODO: static methods
		--TODO: type checking
		--TODO: inheritance
	}
)
