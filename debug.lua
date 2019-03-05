local json = require 'dkjson'
local debuggee = require 'vscode-debuggee'
local startResult, breakerType = debuggee.start(json)
print('debuggee start ->', startResult, breakerType)
xpcall(
	function()
		-- Code to actually run
		dofile('computerRoot/startup')
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
