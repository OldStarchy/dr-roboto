function runWithLogging(func, errDel)
	assertType(func, 'function')
	if (errDel ~= nil) then
		assertType(errDel, 'function')
	end
	local stopFrame = debug.getinfo(2)

	return xpcall(
		func,
		function(originalErr)
			print(originalErr)
			log:error(originalErr)
			if (errDel) then
				errDel(originalErr)
			end

			local trace = getStackTrace(20, 2)
			trace[1] = originalErr

			local start = false
			local startFrame = debug.getinfo(originalErr)
			for _, frameInfo in ipairs(trace) do
				if (_ > 1 and not start) then
					if (frameInfo.source == startFrame.source and frameInfo.currentline == startFrame.currentline) then
						start = true
						frameInfo = startFrame
					end
				end

				if (start) then
					if (frameInfo.source == stopFrame.source and frameInfo.currentline == stopFrame.currentline) then
						break
					end

					local errLine =
						stringutil.join(
						{
							frameInfo.source,
							frameInfo.currentline
						},
						':'
					) .. ':'

					log:error(errLine)

					if (frameInfo.source and frameInfo.currentline) then
						errLine = getFileLines(frameInfo.source, frameInfo.currentline, 3)
						if (errLine ~= nil) then
							log:error('\n\t' .. string.gsub(errLine, '\n', '\n\t') .. '\n\n')
						end
					end
				end
			end
		end
	)
end
