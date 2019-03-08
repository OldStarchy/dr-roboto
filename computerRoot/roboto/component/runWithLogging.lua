function runWithLogging(func, errDel)
	assertType(func, 'function')
	if (errDel ~= nil) then
		assertType(errDel, 'function')
	end
	local stopFrame = getStackFrameInfo(2)

	return xpcall(
		func,
		function(err)
			if (errDel) then
				errDel(err)
			end

			local trace = getStackTrace(20, 2)
			trace[1] = err

			for _, err in ipairs(trace) do
				local frameInfo = getStackFrameInfo(err)

				if (frameInfo.file == stopFrame.file and frameInfo.line == stopFrame.line) then
					break
				end

				local errLine =
					stringutil.join(
					{
						frameInfo.file,
						frameInfo.line,
						frameInfo.message
					},
					':'
				) .. ':'

				log.error(errLine)

				if (frameInfo.file and frameInfo.line) then
					errLine = getFileLines(frameInfo.file, frameInfo.line, 3)
					if (errLine ~= nil) then
						log.error('\n\t' .. string.gsub(errLine, '\n', '\n\t') .. '\n\n')
					end
				end
			end
		end
	)
end
