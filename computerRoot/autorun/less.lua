shell.setCompletionFunction(
	'less.lua',
	function(shell, index, text, previousText)
		local commandWithoutLess = table.concat({select(2, unpack(previousText))}, ' ') .. ' ' .. text
		return shell.complete(commandWithoutLess)
	end
)
