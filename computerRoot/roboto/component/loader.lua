--Runs a file in the same environment (access to global variables) as the caller
-- Similar to require i guess but it doesn't cache anything
-- arguments are passed to the file
function include(module, ...)
	if (module:sub(-(#'.lua')) == '.lua') then
		error('Do not include .lua in module names', 2)
	end

	local fname = nil

	if (fs.exists(module)) then
		fname = module
	elseif (fs.exists(module .. '.lua')) then
		fname = module .. '.lua'
	else
		error('Could not find ' .. module, 2)
	end

	local chunk, err = loadfile(fname, getfenv(2))

	if (chunk ~= nil) then
		return chunk(...)
	else
		error(err, 2)
	end
end

function includeAll(directory)
	if (not fs.exists(directory)) then
		error('Path ' .. directory .. ' does not exist')
	end
	if (not fs.isDir(directory)) then
		error('Path ' .. directory .. ' is not a directory', 2)
	end

	local content = fs.list(directory)

	local loadedAny = false
	local results = {}

	for _, path in ipairs(content) do
		if (stringutil.endsWith(path, '.lua')) then
			if (not fs.isDir(directory .. '/' .. path)) then
				local fullPath = directory .. '/' .. path:sub(1, #path - 4)

				local chunk, err = loadfile(fullPath, getfenv(2))

				if (chunk ~= nil) then
					results[fullPath] = chunk()
					loadedAny = true
				else
					error(err, 2)
				end
			end
		end
	end
	if (not loadedAny) then
		print("Warning, no files found in call to includeAll '" .. directory .. "'")
	end
end

function dofileSandbox(filename, env, ...)
	local chunk, err = loadfile(filename, env)

	if (chunk == nil) then
		error('Could not load file:' .. err, 2)
	end

	return chunk(...)
end

--[[
	Creates a new global environment that can be used to encapsulate global variables
	Its not a real sandbox, but it works for what i'm using it for
	Calling endlocal will restore the environment back to what it was, and return the sandboxed environment table
]]
startlocal = function()
	local oldenv = getfenv(2)
	local env = {}
	local isEnded = false
	env.endlocal = function()
		if (isEnded) then
			return
		end
		isEnded = true
		setfenv(2, oldenv)
		return env
	end
	setfenv(2, setmetatable(env, {__index = oldenv}))
end
