--[[
	Creates a new global environment that can be used to encapsulate global variables
	Its not a real sandbox, but it works for what i'm using it for
	Calling endlocal will restore the environment back to what it was, and return the sandboxed environment table
]]
function startlocal()
	local oldenv = getfenv(2)
	local env = {}
	local isEnded = false

	function env.endlocal()
		if (isEnded) then
			error('Multiple calls to endlocal', 2)
		end

		isEnded = true
		setfenv(2, oldenv)
		return env
	end

	setfenv(2, setmetatable(env, {__index = oldenv}))
end
