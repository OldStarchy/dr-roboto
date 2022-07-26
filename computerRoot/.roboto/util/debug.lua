function getStackTrace(frames, startFrame, maxJump)
	frames = ((type(frames) == 'number') and frames) or 5
	startFrame = ((type(startFrame) == 'number') and startFrame) or 1
	maxJump = ((type(maxJump) == 'number') and maxJump) or 5
	if (frames <= 0) then
		return
	end

	local endFrame = frames + startFrame
	local trace = {}

	for i = startFrame, endFrame do
		local frameInfo = debug.getinfo(i + 1)

		if (frameInfo == nil) then
			return trace
		else
			table.insert(trace, frameInfo)
		end
	end

	return trace
end

-- Will print "frames" stack frames starting from startFrame (defaults to 1, the calling function)
-- Sometimes frames are nil but there are more after
-- empty frames are collapsed and are printed as '-'
-- If maxJump empty frames are found in a row, assume there are no more frames
function printStackTrace(frames, start, jump)
	local trace = getStackTrace(frames, coalesce(start, 2) + 1, jump)

	for i, info in ipairs(trace) do
		print(info.short_src .. ':' .. info.currentline .. ' ' .. coalesce(info.name, '?'))
	end
end

function saveStackTrace(file, frames, start, jump)
	local f = fs.open(file, 'w')
	if (f == nil) then
		printStackTrace(frames, start, jump + 1)
		error('could not save to file')
	end

	local trace = getStackTrace(frames, coalesce(start, 2) + 1, jump)

	for i, info in ipairs(trace) do
		f.write(info.short_src .. ':' .. info.currentline .. ' ' .. coalesce(info.name, '?') .. '\n')
	end

	f.close()
end

function getFileLines(file, line, count)
	if (count == nil) then
		count = 1
	end

	if (fs.exists(file)) then
		local fh = fs.open(file, 'r')
		local content = fh.readAll()
		fh.close()

		local lines = stringutil.split(content, '\n')

		local r = ''
		local start = math.ceil(line - count / 2)
		local ed = start + count - 1

		if (start < 1) then
			start = 1
		end

		if (ed > #lines) then
			ed = #lines
		end
		for i = start, ed do
			r = r .. i .. '\t' .. lines[tonumber(i)] .. '\n'
		end

		return stringutil.trim(r, '\n')
	else
		return nil
	end
end

function runAndPrintErrLines(func)
	xpcall(
		func,
		function(rootErr)
			local lineText = ''

			local trace = getStackTrace(20, 2)
			trace[1] = rootErr

			local fileOutput = ''

			local textColor = term.isColor() and term.getTextColor() or nil

			local first = true
			for _, frameInfo in ipairs(trace) do
				local errLine = nil

				fileOutput = fileOutput .. info.source .. ':' .. frameInfo.currentline .. '\n'

				if (frameInfo.source and frameInfo.currentline >= 0) then
					errLine = getFileLines(frameInfo.source, frameInfo.currentline, 3)
					if (errLine ~= nil) then
						fileOutput = fileOutput .. '\t' .. string.gsub(errLine, '\n', '\n\t') .. '\n\n'
					end
				end

				if (first) then
					if (term.isColour()) then
						term.setTextColor(colours.red)
					end

					print(rootErr)
					print(frameInfo.source .. ':' .. frameInfo.currentline)

					if (term.isColour()) then
						term.setTextColor(colours.orange)
					end

					if (errLine ~= nil) then
						print(errLine)
					end

					first = false
				else
					print(frameInfo.source .. ':' .. frameInfo.currentline)
					if (errLine ~= nil) then
						print(errLine)
					end
				end
			end

			if (term.isColour()) then
				term.setTextColor(textColor)
			end

			file = 'stacktrace.txt'
			local f = fs.open(file, 'w')

			if (f == nil) then
				printStackTrace(10, 2)
				error('could not save to file')
			end
			f.write(fileOutput)
			f.close()
		end
	)
end
