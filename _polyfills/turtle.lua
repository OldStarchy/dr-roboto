-- TODO: restructure test.lua and use the mock object defined there
-- t.mock('turtle', true, 5) for equivalent behavior
local depth = 64
turtle =
	setmetatable(
	{},
	{
		__index = function(t, v)
			return function(...)
				if (v == 'down') then
					if (depth <= 0) then
						return false
					end
					depth = depth - 1
				elseif (v == 'up') then
					if (depth >= 256) then
						return false
					end
					depth = depth + 1
				end
				print('called turtle.' .. v .. '(', unpack({...}), ')')
				-- printStackTrace(5, 2)
				return true
			end
		end
	}
)

return turtle
