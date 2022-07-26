local function printWithIndentation(indentation, directory)
	local dir = fs.list(directory)

	for index, name in pairs(dir) do
		coroutine.yield(indentation .. "+- " .. name)

		local fullpath = fs.combine(directory, name)

		if (fs.isDir(fullpath)) then
			printWithIndentation(indentation .. "|  ", fullpath)
		end
	end
end

-- local function normalizePath(path)


local args = { ... }

if (#args ~= 1) then
	print("Usage: tree <dir>")
	return
end

local dir = args[1]

if (dir:sub(1, 1) ~= '/') then
	dir = fs.combine(shell.dir(), dir)
end

dir = "/" .. dir

print('Printing tree for "' .. dir .. '"')

if (fs.isDir(args[1])) then
	local routine = coroutine.create(printWithIndentation)

	local width, height = term.getSize()

	while (coroutine.status(routine) ~= "dead") do
		for i = 1, height - 4 do
			local success, line = coroutine.resume(routine, "  ", dir)


			if (line == nil) then
				break
			end

			print(line)
		end

		print("press any key to continue...")
		read()
	end
else
	print('"' .. dir .. '" does not exist.')
end
