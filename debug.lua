local json = require 'dkjson'
local debuggee = require 'vscode-debuggee'
local startResult, breakerType = debuggee.start(json)
function debug_break(frame)
	if (debuggee ~= nil) then
		debuggee.enterDebugLoop((frame or 0) + 1, 'debug_break')
	end
end

print('debuggee start ->', startResult, breakerType)
xpcall(
	function()
		-- Code to actually run

		local f = io.open('computerRoot/startup', 'r')
		local str = f:read('*all')
		f:close()
		loadstring(str, 'startup')()
	end,
	function(e)
		if debuggee.enterDebugLoop(1, e) then
			-- ok
		else
			-- If the debugger is not attached, enter here.
			print(e)
			print(debug.traceback())
		end
	end
)
