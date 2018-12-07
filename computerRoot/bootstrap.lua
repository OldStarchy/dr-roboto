local isPc = false

if (os.version == nil) then
	isPc = true
end

if (isPc) then
	dofile '_polyfills/fs.lua'
	dofile '_polyfills/turtle.lua'
	dofile '_polyfills/os.lua'
	dofile '_polyfills/textutils.lua'
	dofile '_polyfills/bit.lua'
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

_G.includeAll = function(directory)
	if (fs.exists(directory)) then
		if (fs.isDir(directory)) then
			local content = fs.list(directory)

			local loaded = false
			for _, path in ipairs(content) do
				print(path)
				if (stringutil.endsWith(path, '.lua')) then
					if (not fs.isDir(directory .. '/' .. path)) then
						include(directory .. '/' .. path)
						loaded = true
					end
				end
			end
			print("Warning, no files found in call to includeAll '" .. directory .. "'")
		else
			error('Path ' .. directory .. ' is not a directory', 2)
		end
	else
		error('Path ' .. directory .. ' does not exist')
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
include 'Util/type'
include 'Util/util'
include 'Util/fs'
include 'Util/math'
include 'Util/string'
include 'Util/table'
include 'Util/Pixel'

--[[
	These functions reference "Class" but Class hasn't been defined yet. This fixes it somehow
]]
setfenv(isType, getfenv(2))
setfenv(assertType, getfenv(2))

local ignoreMissingGlobal = false
local ignoreMissingGlobals = {
	_PROMPT = true,
	_PROMPT2 = true,
	multishell = true
}
setmetatable(
	_G,
	{
		__index = function(t, v)
			if (ignoreMissingGlobals[v] or ignoreMissingGlobal) then
				return nil
			end
			print('Attempt to access missing global "' .. tostring(v) .. '"')
			printStackTrace(2, 2)
			return nil
		end
	}
)

function suppressMissingGlobalWarnings(suppress)
	ignoreMissingGlobal = suppress
end

function isDefined(key)
	ignoreMissingGlobal = true
	local isDef = getfenv(2)[key] ~= nil
	ignoreMissingGlobal = false
	return isDef
end

if (not isPc) then
	local freeSpace = fs.getFreeSpace('.')
	print(tostring(freeSpace) .. 'B of HDD space remaining')
end
