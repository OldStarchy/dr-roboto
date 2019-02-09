function runWithLogging(func)
	local stopFrame = getStackFrameInfo(1)

	return xpcall(
		func,
		function(err)
			local trace = getStackTrace(20, 2)
			trace[1] = err

			for _, err in ipairs(trace) do
				local frameInfo = getStackFrameInfo(err)

				if (frameInfo.file == stopFrame.file) then
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
