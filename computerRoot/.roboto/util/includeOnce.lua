-- includeOnce(IBuffer, './IBuffer') will include `./IBuffer` if IBuffer is nil
-- if only one paramater is passed, the filename is assumed to be the name of a
-- global variable, so includeOnce('./IBuffer') is equivalent to the above

function includeOnce(existing, module)
	if (module == nil) then
		module = existing

		local filename = fs.getName(module)

		if (filename == nil) then
			error('Could not determine export name for "' .. module .. '"', 2)
		end

		if (stringutil.endsWith(filename, '.lua')) then
			filename = filename:sub(1, -5)
		end

		existing = _G[filename]
	end

	if (existing == nil) then
		return include(module)
	end
end
