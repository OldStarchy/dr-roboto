-- Last tested against a very old version of CC

local combine = fs.combine
local fsType = {
	directory = 0,
	textFile = 1,
	binaryFile = 2
}
function VirtualFileSystem(name, maxSize)
	assertType(name, 'string')
	maxSize = assertType(coalesce(maxSize, 999000), 'int')

	local o = {}

	setmetatable(
		o,
		{
			__tostring = function()
				return 'vfs{' .. name .. '}'
			end
		}
	)

	local data = {
		parent = nil,
		type = fsType.directory,
		dir = {},
		readOnly = false,
		size = 0
	}

	function o.data()
		return data
	end

	local function makeDirObj()
		return {
			parent = nil,
			type = fsType.directory,
			dir = {},
			readOnly = nil,
			size = 0
		}
	end

	local function makeFileObj(binary)
		local fo = {
			parent = nil,
			readOnly = nil,
			size = 0,
			locked = false,
			type = fsType.file,
			data = ''
		}

		return fo
	end

	local function openFile(obj, readMode, binaryMode)
		if (obj.locked) then
			error('File is open by another handle', 3)
		end

		if (obj.type == fsType.directory) then
			error("Can't open a dir as a file", 3)
		end

		obj.locked = true

		local handle = {}
		local isOpen = true

		function handle.close()
			isOpen = false
			obj.locked = false
			obj.size = #obj.data
		end

		local head = 0

		if (binaryMode) then
			if (readMode) then
				function handle.read()
					if (not isOpen) then
						error('File handle is closed', 2)
					end
					if (head > #obj.data) then
						return nil
					end

					head = head + 1
					return string.byte(obj.data:sub(head - 1, 1))
				end
			else
				function handle.write(byte)
					if (not isOpen) then
						error('File handle is closed', 2)
					end
					if (type(byte) ~= 'number') then
						return
					end

					if (math.floor(byte) ~= byte) then
						return
					end

					obj.data = obj.data .. string.char(byte)
				end
			end
		else
			if (readMode) then
				function handle.readAll()
					if (not isOpen) then
						error('File handle is closed', 2)
					end

					if (head > #obj.data) then
						return nil
					end

					local r = obj.data:sub(head)
					head = #obj.data + 1
					return r
				end

				function handle.readLine()
					if (not isOpen) then
						error('File handle is closed', 2)
					end
					if (head > #obj.data) then
						return nil
					end

					local pos = obj.data:find('\n', head)
					local s = head

					if (pos == nil) then
						pos = #obj.data
					end
					head = pos + 1

					return obj.data:sub(s, pos - 1)
				end
			else
				function handle.write(str)
					if (not isOpen) then
						error('File handle is closed', 2)
					end
					if (type(str) == 'string') then
						obj.data = obj.data .. str
					end
				end

				function handle.writeLine(str)
					if (not isOpen) then
						error('File handle is closed', 2)
					end

					if (type(str) == 'string') then
						obj.data = obj.data .. str .. '\n'
					end
				end

				function handle.flush()
				end
			end
		end
		return handle
	end

	local function normalizeParts(parts)
		local i = 1

		parts = cloneTable(parts)

		while i <= #parts do
			if (parts[i] == '.' or parts[i] == '') then
				table.remove(parts, i)
			elseif (parts[i] == '..') then
				if (i > 1) then
					table.remove(parts, i)
					table.remove(parts, i - 1)
					i = i - 1
				else
					return nil
				end
			else
				i = i + 1
			end
		end

		return parts
	end

	local function getParts(path)
		return stringutil.split(path, '/')
	end

	local function getPath(obj)
		local parts = {}

		while (obj.parent ~= nil) do
			local cname = nil
			for name, sobj in pairs(obj.parent.dir) do
				if (sobj == obj) then
					cname = name
					break
				end
			end

			if (cname == nil) then
				error('corrupt virtual file system structure')
			end

			table.insert(parts, 1, cname)

			obj = obj.parent
		end

		return stringutil.join(parts, '/')
	end

	local function getObj(path)
		local parts = nil
		if (type(path) == 'string') then
			parts = normalizeParts(getParts(path))
		else
			parts = path
		end

		if (parts == nil) then
			error('Invalid path', 3)
		end

		local c = data

		for _, part in ipairs(parts) do
			if (c.type == fsType.directory) then
				local n = c.dir[part]
				if (n == nil) then
					return nil, getPath(c)
				end
				c = n
			end
		end

		return c, path
	end

	local function cloneObj(obj)
		if (obj == nil) then
			return nil
		end

		local newObj = {
			parent = nil,
			type = obj.type,
			dir = nil,
			readOnly = nil,
			size = obj.size,
			data = obj.data
		}

		if (obj.dir ~= nil) then
			newObj.dir = {}
			for name, sobj in pairs(obj.dir) do
				newObj.dir[name] = cloneObj(sobj)
				newObj.dir[name].parent = newObj
			end
		end

		return newObj
	end

	local function isReadOnly(obj)
		if (obj.readOnly == nil) then
			return isReadOnly(obj.parent)
		end

		return obj.readOnly
	end

	local function makeDirParts(parts)
		local c = data

		for _, part in ipairs(parts) do
			if (c.type == fsType.directory) then
				if (c.dir[part] ~= nil) then
					c = c.dir[part]
				else
					c.dir[part] = makeDirObj()
					c.dir[part].parent = c
					c = c.dir[part]
					r = c
				end
			else
				error(getPath(c) .. ' is not a directory', 2)
			end
		end

		return c
	end

	-- Returns a list of all the files (including subdirectories but not their contents) contained in a directory, as a numerically indexed table.
	-- return: table files
	function o.list(path)
		assertType(path, 'string')

		local obj = getObj(path)

		if (obj.type ~= fsType.directory) then
			error(path .. ' is not a directory', 2)
		end

		local ls = {}

		for name, _ in pairs(obj.dir) do
			table.insert(ls, name)
		end

		return ls
	end

	-- Checks if a path refers to an existing file or directory.
	-- return: boolean exists
	function o.exists(path)
		return getObj(path) ~= nil
	end

	-- Checks if a path refers to an existing directory.
	-- return: boolean isDirectory
	function o.isDir(path)
		local obj = getObj(path)

		if (obj == nil) then
			return false
		end

		return obj.type == fsType.directory
	end

	-- Checks if a path is read-only (i.e. cannot be modified).
	-- return: boolean readonly
	function o.isReadOnly(path)
		local obj, closest = getObj(path)

		if (obj == nil) then
			if (closest == '') then
				return false
			end
			return o.isReadOnly(closest)
		end

		return isReadOnly(obj)
	end

	-- Gets the final component of a pathname.
	-- return: string name
	function o.getName(path)
		local parts = normalizeParts(getParts(path))

		return parts[#parts]
	end

	-- Gets the storage medium holding a path, or nil if the path does not exist.
	-- return: string/nil drive
	function o.getDrive(path)
		return 'vfs{' .. name .. '}'
	end

	-- Gets the size of a file in bytes.
	-- return: number size
	function o.getSize(path)
		local obj = getObj(path)

		if (obj == nil) then
			error('No such file', 2)
		end

		if (obj.type == fsType.directory) then
			-- Matches native implementation
			return 0
		end

		return obj.size
	end

	-- Gets the remaining space on the drive containing the given directory.
	-- return: number space
	function o.getFreeSpace(path)
		return maxSize - data.size
	end

	-- Makes a directory.
	-- return: nil
	function o.makeDir(path)
		local parts = normalizeParts(getParts(path))

		if (parts == nil) then
			error('Invalid path', 2)
		end

		makeDirParts(parts)
	end

	-- Moves a file or directory to a new location.
	-- return: nil
	function o.move(fromPath, toPath)
		o.copy(fromPath, toPath)
		o.delete(fromPath)
	end

	-- Copies a file or directory to a new location.
	-- return: nil
	function o.copy(fromPath, toPath)
		if (o.isReadOnly(toPath)) then
			error('Destination is read-only', 2)
		end

		local files = o.find(fromPath)

		local dst = getObj(toPath)

		if (#files > 1) then
			if (dst == nil or dst.type ~= fsType.directory) then
				error("Can't copy multiple files to a single file. Try makeDir first?", 2)
			end

			for _, file in ipairs(files) do
				local name = o.getName(file)

				local newPath = o.combine(toPath, name)
				if (o.exists(newPath)) then
					error('File ' .. newPath .. ' exists', 2)
				end
			end

			local newObjs = {}
			for _, file in ipairs(files) do
				local name = o.getName(file)
				local obj = getObj(file)
				local newObj = cloneObj(obj)

				newObjs[name] = newObj
			end

			for name, obj in ipairs(newObjs) do
				dst.dir[name] = obj
				obj.parent = dst
			end
		else
			fromPath = files[1]
			local newName = nil
			local newObj = nil
			if (dst == nil) then
				local toParts = normalizeParts(getParts(toPath))

				newName = table.remove(toParts)
				local obj = getObj(fromPath)
				newObj = cloneObj(obj)

				dst = makeDirParts(toParts)
			elseif (dst.type == fsType.directory) then
				newName = o.getName(fromPath)
			end

			dst.dir[newName] = newObj
			newObj.parent = dst
		end
	end

	-- Deletes a file or directory.
	-- return: nil
	function o.delete(path)
		local parts = normalizeParts(getParts(path))

		if (parts == nil) then
			error('Invalid path', 2)
		end

		if (getObj(parts) == nil) then
			return
		end

		if (#parts == 0) then
			error('can not delete root dir', 2)
		end

		local name = table.remove(parts)
		local obj = getObj(parts)

		local dobj = obj.dir[name]

		dobj.parent = nil
		obj.dir[name] = nil
	end

	-- Combines two path components, returning a path consisting of the local path nested inside the base path.
	-- return: string path
	o.combine = combine

	-- Opens a file so it can be read or written.
	-- return: table handle
	function o.open(path, mode)
		if (type(mode) ~= 'string') then
			error('invalid open mode', 2)
		end
		local fsMode = nil
		local binaryMode = false
		local readMode = true
		local shouldClear = false

		if (#mode == 2) then
			if (mode:sub(2, 1) == 'b') then
				binaryMode = true
			else
				error('Invalid file mode', 2)
			end
		end

		if (#mode > 2) then
			error('Invalid file mode', 2)
		end

		if (mode:sub(1, 1) == 'w') then
			readMode = false
			shouldClear = true
		elseif (mode:sub(1, 1) == 'a') then
			readMode = false
			shouldClear = false
		elseif (mode:sub(1, 1) == 'r') then
			readMode = true
			shouldClear = false
		else
			error('Invalid file mode', 2)
		end

		local parts = normalizeParts(getParts(path))
		if (shouldClear) then
			local obj = getObj(parts)
			if (obj ~= nil) then
				if (obj.type == fsType.directory) then
					error("Can't open directory as file", 2)
				end

				o.delete(path)
			end
		end

		local file = getObj(path)
		if (file == nil and readMode) then
			return nil
		end

		if (file == nil) then
			local dir = makeDirParts(getParts(o.getDir(path)))
			file = makeFileObj(binaryMode)

			dir.dir[parts[#parts]] = file
			file.parent = dir
		end

		return openFile(file, readMode, binaryMode)
	end

	-- Searches the computer's files using wildcards.
	-- return: table files
	function o.find(wildcard)
		local parts = normalizeParts(getParts(wildcard))

		if (parts == nil) then
			error('Invalid path', 2)
		end

		local currentSearch = {data}

		for _, part in ipairs(parts) do
			local partPattern = '^' .. part:gsub('*', '.*') .. '$'

			local partResults = {}
			while (#currentSearch > 0) do
				local currObj = table.remove(currentSearch, 1)

				if (currObj.type == fsType.directory) then
					for subObjName, subObj in pairs(currObj.dir) do
						if (subObjName:match(partPattern) ~= nil) then
							table.insert(partResults, subObj)
						end
					end
				end
			end
			currentSearch = partResults
		end

		local results = {}

		for _, obj in ipairs(currentSearch) do
			table.insert(results, getPath(obj))
		end

		return results
	end

	-- Returns the parent directory of path.
	-- return: string parentDirectory
	function o.getDir(path)
		assertType(path, 'string', nil, 2)
		local parts = getParts(path)
		table.remove(parts)
		return stringutil.join(parts, '/')
	end

	-- Returns a list of strings that could be combined with the provided name to produce valid entries in the specified folder.
	-- return: table matches
	-- function o.complete(string partial name, string path [, boolean include files] [, boolean include slashes])
	-- 	error('nyi')
	-- end

	return o
end
