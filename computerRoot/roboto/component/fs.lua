local native = fs
fs = {}
fs.native = native

local currentTarget = native

setmetatable(
	fs,
	{
		__index = function(tbl, key)
			return rawget(currentTarget, key)
		end
	}
)

function fs.redirect(fsTarget)
	currentTarget = fsTarget
end

function fs.listRecursive(directory)
	local results = {}

	local dirsToCheck = {directory}

	while (#dirsToCheck > 0) do
		local currentDirectory = table.remove(dirsToCheck)
		local files = fs.list(currentDirectory)

		for _, file in ipairs(files) do
			if (fs.isDir(file)) then
				if (file ~= '.' and file ~= '..' and file ~= 'rom') then
					table.insert(dirsToCheck, currentDirectory .. '/' .. file)
				end
			else
				table.insert(results, currentDirectory .. '/' .. file)
			end
		end
	end

	return results
end

function fs.readTableFromFile(filename)
	local f = fs.open(filename, 'r')
	if (f == nil) then
		error('File "' .. filename .. '"not found', 2)
	end

	local str = f.readAll()
	f.close()

	return textutils.unserialize(str)
end

function fs.writeTableToFile(filename, tbl)
	local f = fs.open(filename, 'w')
	if (f == nil) then
		error('Could not open file "' .. filename .. '" for writing', 2)
	end
	f.write(serialize(tbl))
	f.close()
end
