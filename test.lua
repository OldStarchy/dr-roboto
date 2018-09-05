require 'Core'

local function createTestParams()
	return {
		assertEqual = function(a, b)
			if (a == b) then
				return
			end

			error('Assert Equal failed', 2)
		end
	}
end

local function errorHandler(err)
	print(err)
end

local testCount = 0
local testPass = 0

function test(name, tester)
	if (type(name) == 'table') then
		for i,v in pairs(name) do
			test(i,v)
		end
		return
	end

	print('Running test "' .. name .. '" ...')

	local testParams = createTestParams()
	local success, result =
		xpcall(
		function()
			tester(testParams)
		end,
		errorHandler
	)

	if (success) then
		print('Test passed.')
		testPass = testPass + 1
	else
		print('Test failed.')
	end
	testCount = testCount + 1
end

print('Running tests...')
print()

require 'tests/ClassTest'

print()
print(testPass .. ' out of ' .. testCount .. ' tests passed.')
