shell.setCompletionFunction(
	'chester.lua',
	function(shell, index, text, previousText)
		local chester = loadfile('chester.lua', _G)()

		return chester.cli:autocomplete(shell, index, text, previousText)
	end
)
