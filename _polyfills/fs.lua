require 'lfs'
_G.fs = {
	list = function(directory)
		local dirs = {}

		for d in lfs.dir(directory) do
			table.insert(dirs, d)
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
		return lfs.attributes(directory) ~= nil
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
	end
}
