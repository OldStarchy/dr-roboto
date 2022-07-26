function dofileSandbox(filename, env, ...)
	local chunk, err = loadfile(filename, env)

	if (chunk == nil) then
		error('Could not load file:' .. err, 2)
	end

	return chunk(...)
end
