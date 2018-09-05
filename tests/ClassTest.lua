test(
	{
		ClassConstructorCalled = function(t)
			local A = Class()

			local constructorCalled = false

			A.constructor = function()
				constructorCalled = true
			end

			local object = A.new()

			t.assertEqual(constructorCalled, true)
		end
	}
)
