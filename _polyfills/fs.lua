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
		local success, result =
			pcall(
			function()
				local files = fs.list(directory)
				return #files > 0
			end
		)

		return success and result
	end,
	getName = function(directory)
		return directory:sub(unpack({directory:find('[^/]+$')}))
	end
}
