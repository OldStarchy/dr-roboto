function getStackTrace(frames, startFrame, maxJump)
	frames = ((type(frames) == 'number') and frames) or 5
	startFrame = ((type(startFrame) == 'number') and startFrame) or 1
	startFrame = startFrame + 3
	maxJump = ((type(maxJump) == 'number') and maxJump) or 5
	if (frames <= 0) then
		return
	end

	local stop = false
	local i = startFrame
	local endFrame = frames + startFrame
	local emptyFrames = 0
	local trace = {}
	while not stop and i < endFrame do
		xpcall(
			function()
				error('', i)
			end,
			function(err)
				if (err == 'bios.lua:883: ') then
					stop = true
				elseif (err == '') then
					if (emptyFrames == 0) then
						table.insert(trace, '-')
					end
					emptyFrames = emptyFrames + 1
					if (emptyFrames > maxJump) then
						stop = true
					else
						endFrame = endFrame + 1
					end
				else
					emptyFrames = 0
					table.insert(trace, err)
				end
			end
		)
		i = i + 1
	end

	return trace
end

-- Will print "frames" stack frames starting from startFrame (defaults to 1, the calling function)
-- Sometimes frames are nil but there are more after
-- empty frames are collapsed and are printed as '-'
-- If maxJump empty frames are found in a row, assume there are no more frames
function printStackTrace(frames, start, jump)
	local trace = getStackTrace(frames, coalesce(start, 2) + 1, jump)

	for i, v in pairs(trace) do
		print(v)
	end
end

function saveStackTrace(file, frames, start, jump)
	local f = fs.open(file, 'w')
	if (f == nil) then
		printStackTrace(frames, start, jump + 1)
		error('could not save to file')
	end

	local trace = getStackTrace(frames, coalesce(start, 2) + 1, jump)

	for i, v in pairs(trace) do
		f.write(v .. '\n')
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

			local first = true
			for _, err in pairs(trace) do
				if (type(err) == 'string') then
					local bits = stringutil.split(err, ':')
					local file = stringutil.trim(bits[1])
					local line = stringutil.trim(bits[2])
					local errLine = nil

					fileOutput = fileOutput .. err .. '\n'

					if (#file > 0 and #line > 0) then
						errLine = getFileLines(file, line, 3)
						if (errLine ~= nil) then
							fileOutput = fileOutput .. '\t' .. string.gsub(errLine, '\n', '\n\t') .. '\n\n'
						end
					end

					if (first) then
						if (term.isColour()) then
							term.setTextColor(colours.red)
						end

						local erro = stringutil.join({select(3, unpack(bits))}, ':')
						print(erro)
						print(file .. ':' .. line)

						if (term.isColour()) then
							term.setTextColor(colours.orange)
						end

						if (errLine ~= nil) then
							print(errLine)
						end

						first = false
					end
				end
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
