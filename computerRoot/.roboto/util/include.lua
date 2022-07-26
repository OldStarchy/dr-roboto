--Runs a file in the same environment (access to global variables) as the caller
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
