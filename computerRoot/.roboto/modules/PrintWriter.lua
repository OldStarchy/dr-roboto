PrintWriter = Class()
PrintWriter.ClassName = 'PrintWriter'

PrintWriter.Colours = {
	info = colours.white,
	warn = colours.orange,
	error = colours.red
}

function PrintWriter:log(typ, message, frameInfo)
	local colour = term.getTextColour()
	if (term.isColour()) then
		term.setTextColour(PrintWriter.Colours[typ])
	end

	print(message)

	term.setTextColour(colour)
end
