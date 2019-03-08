local ignoreMissingGlobal = false
local ignoreMissingGlobals = {
	_PROMPT = true,
	_PROMPT2 = true,
	multishell = true
}
setmetatable(
	_G,
	{
		__index = function(t, v)
			if (ignoreMissingGlobals[v] or ignoreMissingGlobal) then
				return nil
			end
			log.warn('Attempt to access missing global "' .. tostring(v) .. '"')
			debug_break()
			local trace = getStackTrace(2, 2)

			for i, v in pairs(trace) do
				log.warn(v)
			end
			return nil
		end
	}
)
function suppressMissingGlobalWarnings(suppress)
	ignoreMissingGlobal = suppress
end
function isDefined(key)
	ignoreMissingGlobal = true
	local isDef = getfenv(2)[key] ~= nil
	ignoreMissingGlobal = false
	return isDef
end
