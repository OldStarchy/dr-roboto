local isPc = false

if (os.version == nil) then
	isPc = true
else
	_G.loadfile = function(_sFile, _tEnv)
		local file = fs.open(_sFile, 'r')
		if file then
			local func, err = load(file.readAll(), _sFile, 't', _tEnv)
			file.close()
			return func, err
		end
		return nil, 'File not found'
	end
end

if (isPc) then
	dofile '../_polyfills/fs.lua'
	dofile '../_polyfills/turtle.lua'
	dofile '../_polyfills/os.lua'
	dofile '../_polyfills/textutils.lua'
	dofile '../_polyfills/bit.lua'
	dofile '../_polyfills/term.lua'
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

	local fname = nil

	if (fs.exists(module)) then
		fname = module
	elseif (fs.exists(module .. '.lua')) then
		fname = module .. '.lua'
	else
		error('Could not find ' .. module)
	end

	chunk, err = loadfile(fname, getfenv(2))

	if (chunk ~= nil) then
		return chunk(...)
	else
		error(err, 2)
	end
end

_G.includeAll = function(directory)
	setfenv(1, getfenv(2))
	if (fs.exists(directory)) then
		if (fs.isDir(directory)) then
			local content = fs.list(directory)

			local loaded = false
			for _, path in ipairs(content) do
				if (stringutil.endsWith(path, '.lua')) then
					if (not fs.isDir(directory .. '/' .. path)) then
						include(directory .. '/' .. path:sub(1, #path - 4))
						loaded = true
					end
				end
			end
			if (not loaded) then
				print("Warning, no files found in call to includeAll '" .. directory .. "'")
			end
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
