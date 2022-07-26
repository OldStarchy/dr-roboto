test(
	'OO',
	{
		class = {
			Conversion = {
				['With Constructor'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					function A:conversionConstructor(a)
						self.a = a
					end

					local object = {}

					A.ConvertToInstance(object, 'test')

					t.assertEqual(object.a, 'test')
					t.assertEqual(object:getType(), A)
				end,
				['Without Constructor'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local object = {}

					A.ConvertToInstance(object, 'test')

					t.assertEqual(object:getType(), A)
				end
			},
			Constructor = {
				['Called'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local constructorCalled = false

					function A:constructor()
						constructorCalled = true
					end

					local object = A()

					t.assertEqual(constructorCalled, true)
				end,
				['Default'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local object = A()

					t.assertNotEqual(object, nil)
				end,
				['Passes self'] = function(t)
					local A = Class()
					A.ClassName = 'A'

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
					A.ClassName = 'A'

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
					A.ClassName = 'A'

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
					A.ClassName = 'A'

					local object = A()

					t.assertThrows(
						function()
							object:missingMethod()
						end
					)
				end,
				['Passes self'] = function(t)
					local A = Class()
					A.ClassName = 'A'

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
					A.ClassName = 'A'

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
					A.ClassName = 'A'

					local constructorCalled = false
					function A:constructor()
						constructorCalled = true
					end

					local B = Class(A)
					B.ClassName = 'B'

					local object = B()

					t.assertEqual(constructorCalled, true)
				end,
				['Explicit Super Constructor'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local constructorCalled = false
					function A:constructor()
						constructorCalled = true
					end

					local B = Class(A)
					B.ClassName = 'B'
					function B:constructor()
						A.constructor(self)
					end

					local object = B()

					t.assertEqual(constructorCalled, true)
				end,
				['Object Method'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local methodCalled = false
					function A:method()
						methodCalled = true
					end

					local B = Class(A)
					B.ClassName = 'B'

					local object = B()
					object:method()

					t.assertEqual(methodCalled, true)
				end,
				['Object Super Method'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local methodCalled = false
					function A:method()
						methodCalled = true
					end

					local B = Class(A)
					B.ClassName = 'B'

					function B:method()
						A.method(self)
					end

					local object = B()
					object:method()

					t.assertEqual(methodCalled, true)
				end,
				['Static Method'] = function(t)
					local A = Class()
					A.ClassName = 'A'

					local methodCalled = false
					function A.method()
						methodCalled = true
					end

					local B = Class(A)
					B.ClassName = 'B'

					B.method()

					t.assertEqual(methodCalled, true)
				end
			},
			['Get Type'] = function(t)
				local A = Class()
				A.ClassName = 'A'

				local object = A()

				t.assertEqual(object:getType(), A)
			end,
			['Is Type'] = function(t)
				local A = Class()
				A.ClassName = 'A'
				local B = Class(A)
				B.ClassName = 'B'
				local C = Class(B)
				C.ClassName = 'C'

				local object = B()

				t.assertEqual(object:isType(A), true)
				t.assertEqual(object:isType(B), true)
				t.assertEqual(object:isType(C), false)
			end,
			['To String'] = function(t)
				local A = Class()
				A.ClassName = 'A'

				function A:toString()
					return 'custom tostring result'
				end

				local object = A()

				t.assertEqual(tostring(object), 'custom tostring result')
			end,
			['Default To String'] = function(t)
				local A = Class()
				A.ClassName = 'A'

				local object = A()

				local str = tostring(object)

				-- Please don't do this kind of thing outside of tests
				setmetatable(object, nil)

				local nativeStr = tostring(object)

				local expectedStr = nativeStr:gsub('table', 'A')

				t.assertEqual(str, expectedStr)
			end,
			['Is Equal'] = function(t)
				local A = Class()
				A.ClassName = 'A'

				local a = nil
				local b = nil

				function A:isEqual(other)
					return true
				end

				a = A()
				b = A()

				t.assertEqual(a == b, true)
			end,
			['Default Is Equal'] = function(t)
				local A = Class()
				A.ClassName = 'A'

				local a = nil
				local b = nil

				a = A()
				b = A()

				t.assertEqual(a == b, false)
			end,
			['Implements Interface'] = function(t)
				local I = Interface()
				I.amethod = 'function'

				local A = Class(I)
				A.ClassName = 'A'
				function A:amethod()
				end

				local B = Class(I)
				B.ClassName = 'B'
				--Does not implement amethod

				t.assertNotThrows(A.assertImplementation, A)
				t.assertThrows(B.assertImplementation, B)
			end
		},
		Interface = {
			Test = function(t)
				local A = Interface()
				A.method = 'function'
				A.table = 'table'

				t.assertEqual(A.test({}), false)
				t.assertEqual(
					A.test(
						{
							method = function()
							end,
							table = {}
						}
					),
					true
				)
			end,
			Inheritance = {
				Single = function(t)
					local A = Interface()
					A.amethod = 'function'

					local B = Interface(A)
					B.bmethod = 'function'

					local empty = {}
					local aNotB = {
						amethod = function()
						end
					}
					local bNotA = {
						bmethod = function()
						end
					}
					local ab = {
						amethod = function()
						end,
						bmethod = function()
						end
					}

					t.assertEqual(B.test(empty), false)
					t.assertEqual(B.test(aNotB), false)
					t.assertEqual(B.test(bNotA), false)
					t.assertEqual(B.test(ab), true)
				end,
				Multiple = function(t)
					local A = Interface()
					A.amethod = 'function'

					local B = Interface()
					B.bmethod = 'function'

					local C = Interface()
					C.cmethod = 'function'

					local D = Interface(A, B, C)

					local empty = {}
					local aNotB = {
						amethod = function()
						end
					}
					local bNotA = {
						bmethod = function()
						end
					}
					local ab = {
						amethod = function()
						end,
						bmethod = function()
						end
					}
					local abc = {
						amethod = function()
						end,
						bmethod = function()
						end,
						cmethod = function()
						end
					}

					t.assertEqual(D.test(empty), false)
					t.assertEqual(D.test(aNotB), false)
					t.assertEqual(D.test(bNotA), false)
					t.assertEqual(D.test(ab), false)
					t.assertEqual(D.test(abc), true)
				end
			}
		}
	}
)
