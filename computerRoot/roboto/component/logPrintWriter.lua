local printWriter = {}

printWriter.colours = {
	info = colours.white,
	warn = colours.orange,
	error = colours.red
}

function printWriter.log(typ, message, frameInfo)
	local colour = term.getTextColour()
	if (term.isColour()) then
		term.setTextColour(printWriter.colours[typ])
	end

	print(message)

	term.setTextColour(colour)
end

return printWriter
