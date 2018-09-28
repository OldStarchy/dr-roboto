-- Will print "frames" stack frames starting from startFrame (defaults to 1, the calling function)
-- Sometimes frames are nil but there are more after
-- empty frames are collapsed and are printed as '-'
-- If maxJump empty frames are found in a row, assume there are no more frames
function printStackTrace(frames, startFrame, maxJump)
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
	while not stop and i < endFrame do
		xpcall(
			function()
				error('', i)
			end,
			function(err)
				if (err == '') then
					if (emptyFrames == 0) then
						print('-')
					end
					emptyFrames = emptyFrames + 1
					if (emptyFrames > maxJump) then
						stop = true
					else
						endFrame = endFrame + 1
					end
				else
					emptyFrames = 0
					print(err)
				end
			end
		)
		i = i + 1
	end
end
