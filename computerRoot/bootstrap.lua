local isPc = false

if (os.version == nil) then
	isPc = true
end

if (isPc) then
	dofile '_polyfills/fs.lua'
	dofile '_polyfills/turtle.lua'
	dofile '_polyfills/os.lua'
	dofile '_polyfills/textutils.lua'
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
end

function dofileSandbox(filename, env)
	local status, result = assert(pcall(setfenv(assert(loadfile(filename)), env)))
	return result
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

if (read == nil) then
	read = function()
		return ''
	end
end

include 'Util/debug'
include 'Util/startlocal'
include 'Util/string'
include 'Util/table'

local ignoreMissingGlobals = {
	_PROMPT = true,
	_PROMPT2 = true
}
setmetatable(
	_G,
	{
		__index = function(t, v)
			if (ignoreMissingGlobals[v]) then
				return nil
			end
			print('Attempt to access missing global "' .. tostring(v) .. '"')
			printStackTrace(1, 2)
			return nil
		end
	}
)
