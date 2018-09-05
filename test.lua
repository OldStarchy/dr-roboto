require 'Core'
local col = require 'TextColors'

local function createTestParams()
	return {
		assertEqual = function(a, b)
			if (a == b) then
				return
			end

			error('Assert == failed', 2)
		end,
		assertNotEqual = function(a, b)
			if (a ~= b) then
				return
			end

			error('Assert ~= failed', 2)
		end
	}
end

local function doTest(name, tester)
	local testParams = createTestParams()
	local errors = {}
	local success, result =
		xpcall(
		function()
			tester(testParams)
		end,
		function(err)
			table.insert(errors, err)
		end
	)

	return success, errors
end

local tests = {}

--[[
	Prepares tests for execution.
	
	Tester functions are invoked using xpcall. If the function returns; the test passes, if it errors; it fails.

	A "testing table" is a recursive structure for tests. A value can be either a tester function, or another testing table.
	If the value is a function, then the key is the test's name, if the value is a table, then the key is a subnamespace that gets appended to the current namespace using dot notation.

	The testing table below yields 3 tests
	test({
		['Core'] = {
			['My Tests'] = {
				['Test 1'] = function(t) end
				['Test 2'] = function(t) end
			}
		},
		['Aux'] = function(t) end
	})

	- Core.My Tests.Test 1
	- Core.My Tests.Test 2
	- Aux

	Tests are not guarenteed to execute in the same order they are written. This is due to the way lua tables work.

	To fit in the standard ComputerCraft window, test names should be 37 or less characters and (fully concatenated) namespaces should be 37 characters or less

	test(namespace: string, name: string, tester: function) prepares a test for execution
	test(namespace: string, tests: table) prepares a testing table for execution
	test(tests: table) prepares a testing table for execution
]]
function test(namespace, name, tester)
	if (type(namespace) == 'table') then
		test('', namespace)
		return
	end

	if (type(name) == 'table') then
		for i, v in pairs(name) do
			test(namespace, i, v)
		end
		return
	end

	if (type(tester) == 'table') then
		if (namespace == '') then
			namespace = name
		else
			namespace = namespace .. '.' .. name
		end
		test(namespace, tester)
		return
	end

	table.insert(
		tests,
		{
			namespace = namespace,
			name = name,
			tester = tester
		}
	)
end

local LOG_NONE = -1
local LOG_SOME = 0
local LOG_ALL = 1
function runTests(logLevel)
	local testPass = 0

	if (logLevel == nil) then
		logLevel = 0
	end

	local lastNamespace = ''
	local loggedAny = false
	for _, v in ipairs(tests) do
		if (lastNamespace ~= v.namespace and v.namespace ~= nil) then
			if (logLevel > LOG_SOME) then
				col.print(col.blue .. '[' .. v.namespace .. ']\n')
			end
			lastNamespace = v.namespace
		end

		if (logLevel > LOG_ALL) then
			loggedAny = true
			if (#v.name > 37) then
				io.write(string.sub(v.name, 1, 37) .. ':')
			else
				io.write(v.name .. string.rep(' ', 37 - #v.name) .. ':')
			end
		end

		local oldwrite = io.write
		local oldprint = print
		local printlines = {}

		io.write = function(...)
			table.insert(printlines, {'write', {...}})
		end
		print = function(...)
			table.insert(printlines, {'print', {...}})
		end

		local success, errors = doTest(v.name, v.tester)

		io.write = oldwrite
		print = oldprint

		if (success) then
			testPass = testPass + 1
		end

		if (logLevel > LOG_ALL) then
			if (success) then
				col.print(col.green, 'O\n')
			else
				col.print(col.red, 'X\n')
			end

			for i = 1, #printlines do
				if (printlines[i][1] == 'write') then
					io.write(unpack(printlines[i][2]))
				else
					print(unpack(printlines[i][2]))
				end
			end

			for _, v in ipairs(errors) do
				col.print(col.red, ' ' .. v)
			end
		end
	end

	if (logLevel > LOG_ALL or loggedAny) then
		print()
	end
	if (logLevel > LOG_SOME or testPass ~= #tests) then
		print(testPass .. ' out of ' .. #tests .. ' tests passed.')
	end
end

require 'tests/ClassTest'
print('Running startup tests...')
print()
runTests(2)
