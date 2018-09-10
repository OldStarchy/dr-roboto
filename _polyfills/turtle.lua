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
