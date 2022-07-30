local ignoreMissingGlobal = true
local ignoreMissingGlobals = {
	_PROMPT = true,
	_PROMPT2 = true,
	multishell = true
}

local function apply(obj)
	setmetatable(
		obj,
		{
			__index = function(t, v)
				if (ignoreMissingGlobals[v] or ignoreMissingGlobal) then
					return nil
				end
				ignoreMissingGlobal = true

				local printer = log and function(...)
						log:warn(...)
					end or print

				printer('Attempt to access missing global "' .. tostring(v) .. '"')
				debug_break()
				local info = debug.getinfo(2)
				printer(info.source .. ':' .. info.currentline)
				local trace = getStackTrace(2, 2)

				for i, info in ipairs(trace) do
					printer(info.short_src .. ':' .. info.currentline .. ' ' .. coalesce(info.name, '?'))
				end
				ignoreMissingGlobal = false
				return nil
			end
		}
	)

	function obj.suppressMissingGlobalWarnings(suppress)
		ignoreMissingGlobal = suppress
	end

	-- This kind of api is questionable
	function obj.isDefined(key)
		ignoreMissingGlobal = true
		local isDef = getfenv(2)[key] ~= nil
		ignoreMissingGlobal = false
		return isDef
	end
end

apply(_G)
