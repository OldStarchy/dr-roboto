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
	end
}
