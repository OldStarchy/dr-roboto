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
