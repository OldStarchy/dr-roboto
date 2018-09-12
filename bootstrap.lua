if (_G.fs == nil) then
	dofile '_polyfills/fs.lua'
	if (_G.turtle == nil) then
		dofile '_polyfills/turtle.lua'
	end
end

if (os.loadAPI == nil) then
	dofile '_polyfills/os.lua'
end

if (_G.require == nil) then
	dofile '_polyfills/require.lua'
end

if (fs.listRecursive == nil) then
	function fs.listRecursive(directory)
		local results = {}

		local dirsToCheck = {directory}

		while (#dirsToCheck > 0) do
			local currentDirectory = table.remove(dirsToCheck)
			local files = fs.list(currentDirectory)

			for _, file in ipairs(files) do
				if (fs.isDir(file)) then
					if (file ~= '.' and file ~= '..') then
						table.insert(dirsToCheck, currentDirectory .. '/' .. file)
					end
				else
					table.insert(results, currentDirectory .. '/' .. file)
				end
			end
		end

		return results
	end

	function dofileSandbox(filename, env)
		local status, result = assert(pcall(setfenv(assert(loadfile(filename)), env)))
		return result
	end

	function starts_with(str, start)
		return str:sub(1, #start) == start
	end

	function ends_with(str, ending)
		return ending == '' or str:sub(-(#ending)) == ending
	end

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
end

--[[
	Creates a new global environment that can be used to encapsulate global variables
	Its not a real sandbox, but it works for what i'm using it for
	Calling endlocal will restore the environment back to what it was, and return the sandboxed environment table
]]
_G.startlocal = function()
	local oldenv = getfenv(2)
	local env = {}
	local isEnded = false
	env._G = env
	env.endlocal = function()
		if (isEnded) then
			return
		end
		isEnded = true
		setfenv(2, oldenv)
		return env
	end
	setfenv(2, setmetatable(env, {__index = _G}))
end

--Runs a file in the same environment (access to global variables) as the caller
-- Similar to require i guess but it doesn't cache anything
-- arguments are passed to the file
_G.include = function(module, ...)
	if (module:sub(-(#'.lua')) == '.lua') then
		error('Do not include .lua in module names', 2)
	end

	local chunk, err

	if (fs.exists(module)) then
		chunk, err = loadfile(module)
	elseif (fs.exists(module .. '.lua')) then
		chunk, err = loadfile(module .. '.lua')
	else
		error('Could not find ' .. module)
	end

	if (chunk ~= nil) then
		setfenv(chunk, getfenv(2))
		return chunk(...)
	else
		error(err, 2)
	end
end

if (sleep == nil) then
	sleep = function()
	end
end

--[[
turtle.attackUp()

turtle.craft(number: quantity)

(returns:.*)\n(turtle\..*)\n(.*)
"$2": {\n"prefix": "$2",\n"body": [\n\t"$2"\n],\n"description": "$3. $1"\n},\n\n


]]
