if (_G.require == nil) then
	--Running in ComputerCraft
	--This require function mostly emulates the one in normal lua 5.1
	--Will get confused if called both with and without '.lua' extension

	_G.package =
		setmetatable(
		{},
		{
			__index = {
				loaded = setmetatable(
					{},
					{
						__metatable = {}
					}
				)
			},
			__metatable = {},
			__newindex = function()
				error("'package' is read only")
			end
		}
	)
	local currentlyLoading = {}

	_G.require = function(module)
		if (module:sub(-(#'.lua')) == '.lua') then
			error('Do not include .lua in module names')
		end

		if (_G.package.loaded[module]) then
			return _G.package.loaded[module]
		end

		if (currentlyLoading[module]) then
			error('Recursive module loading not supported')
		end

		currentlyLoading[module] = true

		if (fs.exists(module)) then
			_G.package.loaded[module] = dofile(module)
		elseif (fs.exists(module .. '.lua')) then
			_G.package.loaded[module] = dofile(module .. '.lua')
		else
			error('Could not load ' .. module)
		end

		currentlyLoading[module] = nil

		return _G.package.loaded[module]
	end
end

if (_G.fs == nil) then
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
		end
	}
end
