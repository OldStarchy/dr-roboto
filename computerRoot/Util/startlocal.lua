--[[
	Creates a new global environment that can be used to encapsulate global variables
	Its not a real sandbox, but it works for what i'm using it for
	Calling endlocal will restore the environment back to what it was, and return the sandboxed environment table
]]
_G.startlocal = function()
	local oldenv = getfenv(2)
	local env = {}
	local isEnded = false
	env.endlocal = function()
		if (isEnded) then
			return
		end
		isEnded = true
		setfenv(2, oldenv)
		return env
	end
	setfenv(2, setmetatable(env, {__index = oldenv}))
end
