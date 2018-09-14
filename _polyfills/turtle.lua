-- TODO: restructure test.lua and use the mock object defined there
-- t.mock('turtle', true, 5) for equivalent behavior
turtle =
	setmetatable(
	{},
	{
		__index = function(t, v)
			return function(...)
				print('called turtle.' .. v .. '(', unpack({...}), ')')
				printStackTrace(5, 2)
				return true
			end
		end
	}
)

return turtle
