test(
	'Class',
	{
		Constructor = {
			['Called'] = function(t)
				local A = Class()

				local constructorCalled = false

				function A:constructor()
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

				function A:constructor()
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

				function A:constructor(a, b, c)
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

				function A.method()
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

				function A:method()
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

				function A:method(a, b, c)
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
		},
		--TODO: static methods
		--TODO: type checking
		['Inherited'] = {
			['Default Constructor'] = function(t)
				local A = Class()

				local constructorCalled = false
				function A:constructor()
					constructorCalled = true
				end

				local B = Class(A)

				local object = B.new()

				t.assertEqual(constructorCalled, true)
			end,
			['Explicit Super Constructor'] = function(t)
				local A = Class()

				local constructorCalled = false
				function A:constructor()
					constructorCalled = true
				end

				local B = Class(A)
				function B:constructor()
					self.super.constructor(self)
				end

				local object = B.new()

				t.assertEqual(constructorCalled, true)
			end,
			['Object Method'] = function(t)
				local A = Class()

				local methodCalled = false
				function A:method()
					methodCalled = true
				end

				local B = Class(A)

				local object = B.new()
				object:method()

				t.assertEqual(methodCalled, true)
			end,
			['Object Super Method'] = function(t)
				local A = Class()

				local methodCalled = false
				function A:method()
					methodCalled = true
				end

				local B = Class(A)

				function B:method()
					self.super.method(self)
				end

				local object = B.new()
				object:method()

				t.assertEqual(methodCalled, true)
			end,
			['Static Method'] = function(t)
				local A = Class()

				local methodCalled = false
				function A.method()
					methodCalled = true
				end

				local B = Class(A)

				B.method()

				t.assertEqual(methodCalled, true)
			end,
			['Super is parent'] = function(t)
				local A = Class()
				local B = Class(A)

				local super = nil

				function B:constructor()
					super = self.super
				end

				t.assertEqual(super, A)
			end,
			['Super in parent'] = function(t)
				local A = Class()

				local methodCalled = false
				local super = nil

				function A:method()
					methodCalled = true
					super = self.super
				end

				local B = Class(A)

				B:method()

				t.assertEqual(methodCalled, true)
				t.assertEqual(super, nil)
			end
		}
	}
)
