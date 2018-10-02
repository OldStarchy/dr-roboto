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

--for i=0,100 do stringutil.progressBar(i, 100); sleep(0.02) end
stringutil = endlocal()
