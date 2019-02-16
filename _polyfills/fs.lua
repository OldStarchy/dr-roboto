require 'lfs'
_G.fs = {
	list = function(directory)
		local dirs = {}

		if (directory == nil or directory == '') then
			directory = '.'
		else
			directory = './' .. directory
		end

		for d in lfs.dir(directory) do
			if (d ~= '.' and d ~= '..') then
				table.insert(dirs, d)
			end
		end

		return dirs
	end,
	isDir = function(directory)
		return lfs.attributes(directory, 'mode') == 'directory'
	end,
	getName = function(directory)
		return directory:sub(unpack({directory:find('[^/]+$')}))
	end,
	exists = function(directory)
		directory = fs.combine('.', directory)

		if (directory == '' or directory == '.' or directory == '/') then
			return true
		end

		local parentDir = fs.combine(directory, '..')

		local content = fs.list(parentDir)

		for _, v in ipairs(content) do
			local fname = fs.combine(parentDir, v)
			if (fname == directory) then
				return true
			end
		end
		return false
	end,
	open = function(filename, args)
		local f = io.open(filename, args)

		if (f == nil) then
			return nil
		end

		return setmetatable(
			{
				readAll = function()
					return f:read('*a')
				end
			},
			{
				__index = function(_, key)
					if (type(f[key]) == 'function') then
						return function(...)
							f[key](f, ...)
						end
					end
					return f[key]
				end
			}
		)
	end,
	delete = os.remove,
	move = function(source, destination)
		if (fs.exists(destination)) then
			error('Destination exists', 2)
		end

		if (not fs.exists(source)) then
			error('Source file does not exist', 2)
		end
		local s = fs.open(source, 'r')
		local data = s.readAll()
		s.close()

		local d = fs.open(destination, 'w')
		d.write(data)
		d.close()

		fs.delete(source)
	end,
	makeDir = function(dest)
		return lfs.mkdir(dest)
	end,
	combine = function(a, b)
		local fullPath

		if (a == nil and b == nil) then
			error('must specify paths to combine')
		end
		if (a == nil) then
			fullPath = b
		elseif (b == nil) then
			fullPath = a
		else
			fullPath = a .. '/' .. b
		end

		local parts = stringutil.split(fullPath, '/')

		local result = {}

		for i, v in ipairs(parts) do
			if (v ~= '.') then
				if (v == '..') then
					if (#result == 0) then
						return nil
					end

					table.remove(result)
				elseif (v ~= '') then
					table.insert(result, v)
				end
			end
		end

		return table.concat(result, '/')
	end
}
