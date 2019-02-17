local path = ''
local run = true
local foregroundColor = colours.yellow
local internalCommands

local shellEnvironment

local function getSearchPath()
	return {
		path,
		'rom/programs'
	}
end

local function printPrompt()
	term.setTextColour(foregroundColor)
	term.write(path .. '>')
	term.setTextColour(colours.white)
end

local function resolvePath(dir)
	if (dir == nil) then
		return path
	end

	if (dir:sub(1, 1) == '/') then
		return dir:sub(2)
	end

	return fs.combine(path, dir)
end

local function searchPath(dir)
	if (dir:sub(1, 1) == '/') then
		return dir:sub(2)
	end

	for _, pth in ipairs(getSearchPath()) do
		local potential = fs.combine(pth, dir)
		if (fs.exists(potential)) then
			return potential
		end
	end

	return nil
end

local function resolveCommand(cmd)
	local localFile = searchPath(cmd)

	if (localFile ~= nil and fs.exists(localFile)) then
		return loadfile(localFile, shellEnvironment)
	end

	if (internalCommands[cmd]) then
		return internalCommands[cmd]
	end

	return nil
end

local function runCommand(input)
	--TODO: doesn't handle quoted strings
	local args = stringutil.split(input, ' ')

	local cmd = table.remove(args, 1)
	if (cmd == nil) then
		return
	end

	local command = resolveCommand(cmd)

	if (command ~= nil) then
		command(unpack(args))
	else
		print('"' .. cmd .. '" is not an internal or external command')
	end
end

shellEnvironment = {
	shell = {
		dir = function()
			return path
		end,
		resolve = function(dir)
			return resolvePath(dir)
		end
	}
}

setmetatable(shellEnvironment, {__index = _G})

internalCommands = {
	exit = function()
		print('Exiting shell')
		run = false
	end,
	cd = function(dir)
		dir = resolvePath(dir)

		if (dir == nil) then
			print('Not a directory')
			return
		end

		if (fs.exists(dir)) then
			path = dir
		else
			print('Not a directory')
		end
	end,
	list = function(dir)
		dir = resolvePath(dir)
		if (dir == nil or not fs.exists(dir)) then
			print('Not a directory')
		end

		local files = fs.list(dir)

		for _, v in ipairs(files) do
			print(v)
		end
	end,
	which = function(dir)
		if (dir ~= nil) then
			print(searchPath(dir))
		end
	end
}

if (isDefined('interactiveLua')) then
	internalCommands.lua = interactiveLua
end

while (run) do
	printPrompt()

	local input

	--pcall handles ctrl+c (pc) and ctrl+t (cc) and exits gracefully
	if
		(not pcall(
			function()
				input = read()
			end
		))
	 then
		input = 'exit'
		print('terminated')
	end

	if (input ~= nil) then
		runCommand(input)
	end
end
