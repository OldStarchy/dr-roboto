startlocal()

function startsWith(str, start)
	return start == '' or str:sub(1, #start) == start
end

function endsWith(str, ending)
	return ending == '' or str:sub(-(#ending)) == ending
end

function isLower(str)
	return str:lower() == str
end

function isUpper(str)
	return str:upper() == str
end

function writeAt(x, y, str)
	term.setCursorPos(x, y)
	term.write(str)
end
function progressBar(progress, max, row, startCol, endCol)
	if (row == nil) then
		row = select(2, term.getCursorPos())
	end

	if (startCol == nil) then
		startCol = 1
	end

	if (endCol == nil) then
		endCol = term.getSize()
	end

	if (startCol == endCol) then
		error("startCol and endCol can't be equal", 2)
	end

	if (startCol > endCol) then
		startCol, endCol = endCol, startCol
	end

	if (progress > max) then
		progress = max
	end

	local innerWidth = endCol - startCol - 1

	if (innerWidth == 0) then
		writeAt(startCol, row, '[]')
		return
	end

	local dots = math.floor(progress * innerWidth / max)
	local spaces = innerWidth - dots

	writeAt(startCol, row, '[' .. string.rep('.', dots) .. string.rep(' ', spaces) .. ']')
end

--for i=0,100 do stringutil.progressBar(i, 100); sleep(0.02) end
stringutil = endlocal()
