--Runs a file in the same environment (access to global variables) as the caller
-- arguments are passed to the file
function include(module, ...)
	if (module:sub(-(#'.lua')) == '.lua') then
		error('Do not include .lua in module names', 2)
	end

	if (stringutil.startsWith(module, '.')) then
		local callerIndex = 2
		if (debug.getinfo(callerIndex, 'f').func == includeOnce) then
			callerIndex = callerIndex + 1
		end

		local info = debug.getinfo(callerIndex, 'S')
		local callerSource = info.source
		if (not fs.exists(callerSource)) then
			error('Could not determine relative path"' .. module .. '"', 2)
		end
		local callerPath = fs.getDir(callerSource)
		module = fs.combine(callerPath, module)
	end

	local fname = nil

	if (fs.exists(module) and not fs.isDir(module)) then
		fname = module
	elseif (fs.exists(module .. '.lua') and not fs.isDir(module .. '.lua')) then
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
