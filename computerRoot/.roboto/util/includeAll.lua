function includeAll(directory)
	if (not fs.exists(directory)) then
		error('Path ' .. directory .. ' does not exist', 2)
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
				local fullPath = directory .. '/' .. path

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
