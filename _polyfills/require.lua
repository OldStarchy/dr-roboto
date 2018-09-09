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
		error('Do not include .lua in module names', 2)
	end

	if (_G.package.loaded[module]) then
		return _G.package.loaded[module]
	end

	if (currentlyLoading[module]) then
		error('Recursive module loading not supported', 2)
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
