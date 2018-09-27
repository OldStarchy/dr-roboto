registerUserFunction(print, 'print', 'args...')

registerUserFunction(
	function()
		print("The 'run' command grants easy access to commonly used scripts or functions")
		print("See 'UserFunctions/*Functions.lua' for examples (including this help) text.")
	end,
	'help'
)
