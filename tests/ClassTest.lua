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

				local object = A()

				t.assertEqual(constructorCalled, true)
			end,
			['Missing'] = function(t)
				local A = Class()

				local object = A()
			end,
			['Passes self'] = function(t)
				local A = Class()

				local selfValue = nil

				function A:constructor()
					selfValue = self
				end

				local object = A()

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
				local object = A(5, 'blah', tmpTable)

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

				local object = A()
				object:method()

				t.assertEqual(methodCalled, true)
			end,
			['Missing'] = function(t)
				local A = Class()

				local object = A()

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

				local object = A()
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
				local object = A()
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
		Inheritance = {
			['Default Constructor'] = function(t)
				local A = Class()

				local constructorCalled = false
				function A:constructor()
					constructorCalled = true
				end

				local B = Class(A)

				local object = B()

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
					A.constructor(self)
				end

				local object = B()

				t.assertEqual(constructorCalled, true)
			end,
			['Object Method'] = function(t)
				local A = Class()

				local methodCalled = false
				function A:method()
					methodCalled = true
				end

				local B = Class(A)

				local object = B()
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
					A.method(self)
				end

				local object = B()
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
			end
		},
		['Get Type'] = function(t)
			local A = Class()

			local object = A()

			t.assertEqual(object:getType(), A)
		end,
		['Is Type'] = function(t)
			local A = Class()
			local B = Class(A)
			local C = Class(B)

			local object = B()

			t.assertEqual(object:isType(A), true)
			t.assertEqual(object:isType(B), true)
			t.assertEqual(object:isType(C), false)
		end,
		['To String'] = function(t)
			local A = Class()

			function A:toString()
				return 'custom tostring result'
			end

			local object = A()

			t.assertEqual(tostring(object), 'custom tostring result')
		end,
		['Default To String'] = function(t)
			local A = Class()

			local object = A()

			local str = tostring(object)

			-- Please don't do this kind of thing outside of tests
			setmetatable(object, nil)

			local nativeStr = tostring(object)

			local expectedStr = nativeStr:gsub('table', 'class')

			t.assertEqual(str, expectedStr)
		end
	}
)
